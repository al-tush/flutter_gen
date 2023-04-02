import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class AssetType {
  AssetType({
    required this.rootPath,
    required this.path,
    this.isThemed = false,
  });

  final String rootPath;
  final String path;
  final bool isThemed;

  final List<AssetType> _children = List.empty(growable: true);

  bool get isDefaultAssetsDirectory => path == 'assets' || path == 'asset';

  String? get mime => lookupMimeType(path);

  /// https://api.flutter.dev/flutter/widgets/Image-class.html
  bool get isSupportedImage {
    switch (mime) {
      case 'image/jpeg':
      case 'image/png':
      case 'image/gif':
      case 'image/bmp':
      case 'image/vnd.wap.wbmp':
      case 'image/webp':
        return true;
      default:
        return false;
    }
  }

  bool get isIgnoreFile {
    switch (baseName) {
      case '.DS_Store':
        return true;
    }

    switch (extension) {
      case '.DS_Store':
      case '.swp':
        return true;
    }

    return false;
  }

  bool get isUnKnownMime => mime == null;

  String get extension => p.extension(path);

  String get baseName => p.basenameWithoutExtension(path);

  List<AssetType> get children => _children.sortedBy((e) => e.path);

  static const _light = '_light';
  static const _dark = '_dark';

  String get pathWithoutTheme {
    var name = p.withoutExtension(path);
    if (name.endsWith(_light)) {
      name = name.substring(0, name.length - _light.length);
    } else if (name.endsWith(_dark)) {
      name = name.substring(0, name.length - _dark.length);
    }
    return name + extension;
  }

  String pathThemed1() {
    if (!isThemed) return path;
    return '${p.withoutExtension(path)}$_light$extension';
  }

  String pathThemed2() {
    assert(isThemed);
    return '${p.withoutExtension(path)}$_dark$extension';
  }

  void addChild(AssetType type) {
    _children.add(type);
  }
}

class AssetTypeIsUniqueWithoutExtension {
  AssetTypeIsUniqueWithoutExtension({
    required this.assetType,
    required this.isUniqueWithoutExtension,
  });

  final AssetType assetType;
  final bool isUniqueWithoutExtension;
}

extension AssetTypeIterable on Iterable<AssetType> {

  Iterable<AssetType> groupToThemes() {
    return groupBy((e) => p.withoutExtension(e.pathWithoutTheme))
        .values
        .map(
          (list) {
            if (list.length == 2 && list[0].extension == list[1].extension) {
              return [AssetType(rootPath: list[0].rootPath, path: list[0].pathWithoutTheme, isThemed: true)];
            }
            return list;
          }
    )
        .flatten();
  }
  
  Iterable<AssetTypeIsUniqueWithoutExtension> mapToIsUniqueWithoutExtension() {
    return groupBy((e) => p.withoutExtension(e.path))
        .values
        .map(
          (list) => list.map(
            (e) => AssetTypeIsUniqueWithoutExtension(
              assetType: e,
              isUniqueWithoutExtension: list.length == 1,
            ),
          ),
        )
        .flatten();
  }
}
