const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const plutovg = b.addLibrary(.{
        .name = "plutovg",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        .version = try .parse("1.1.0"),
    });
    plutovg.root_module.addCMacro("PLUTOVG_BUILD_STATIC", "1");
    plutovg.installHeader(b.path("include/plutovg.h"), "plutovg.h");
    plutovg.addIncludePath(b.path("include"));
    plutovg.addCSourceFiles(.{
        .root = b.path("source"),
        .files = &.{
            "plutovg-blend.c",
            "plutovg-canvas.c",
            "plutovg-font.c",
            "plutovg-ft-math.c",
            "plutovg-ft-raster.c",
            "plutovg-ft-stroker.c",
            "plutovg-matrix.c",
            "plutovg-paint.c",
            "plutovg-path.c",
            "plutovg-rasterize.c",
            "plutovg-surface.c",
        },
    });
    b.installArtifact(plutovg);

    // used basically only for svg
    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
    });

    const plutosvg = b.addLibrary(.{
        .name = "plutosvg",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        .version = try .parse("0.0.7"),
    });
    plutosvg.root_module.addCMacro("PLUTOSVG_BUILD_STATIC", "1");
    // so it doesnt try import it
    plutosvg.root_module.addCMacro("PLUTOVG_BUILD_STATIC", "1");
    plutosvg.root_module.addCMacro("PLUTOSVG_HAS_FREETYPE", "1");
    plutosvg.linkLibrary(freetype_dep.artifact("freetype"));
    plutosvg.linkLibrary(plutovg);
    plutosvg.installHeader(b.path("include/plutosvg.h"), "plutosvg.h");
    plutosvg.addIncludePath(b.path("include"));
    plutosvg.addCSourceFile(.{
        .file = b.path("source/plutosvg.c"),
    });
    b.installArtifact(plutosvg);
}
