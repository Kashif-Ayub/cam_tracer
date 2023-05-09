import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CachedNetworkTileProvider extends TileProvider {
  final String baseUrl;
  final int tileSize;
  final int maxZoom;
  Map<String, Uint8List> _tiles = {};

  CachedNetworkTileProvider({
    required this.baseUrl,
    required this.tileSize,
    required this.maxZoom,
  });

  Future<void> preloadTiles() async {
    for (var z = 0; z <= maxZoom; z++) {
      final tilesCount = pow(2, z);
      for (var x = 0; x < tilesCount; x++) {
        for (var y = 0; y < tilesCount; y++) {
          final tileUrl = '$baseUrl/$z/$x/$y.png';
          final file = await DefaultCacheManager().getSingleFile(tileUrl);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            _tiles[tileUrl] = bytes;
          } else {
            try {
              final response = await http.get(Uri.parse(tileUrl));
              if (response.statusCode == 200) {
                final bytes = response.bodyBytes;
                final tempFile = await File(
                        '${(await getTemporaryDirectory()).path}/$tileUrl')
                    .create(recursive: true);
                await tempFile.writeAsBytes(bytes);
                await DefaultCacheManager()
                    .putFile(tileUrl, tempFile.readAsBytesSync());
                _tiles[tileUrl] = bytes;
              }
            } catch (e) {
              print('Failed to load tile: $tileUrl, error: $e');
            }
          }
        }
      }
    }
  }

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final tileUrl = '$baseUrl/$zoom/$x/$y.png';
    if (_tiles.containsKey(tileUrl)) {
      return Tile(tileSize, tileSize, _tiles[tileUrl]!);
    } else {
      final file = await DefaultCacheManager().getSingleFile(tileUrl);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        _tiles[tileUrl] = bytes;
        return Tile(tileSize, tileSize, bytes);
      } else {
        try {
          final response = await http.get(Uri.parse(tileUrl));
          if (response.statusCode == 200) {
            final bytes = response.bodyBytes;
            final tempFile =
                await File('${(await getTemporaryDirectory()).path}/$tileUrl')
                    .create(recursive: true);
            await tempFile.writeAsBytes(bytes);
            await DefaultCacheManager()
                .putFile(tileUrl, tempFile.readAsBytesSync());
            _tiles[tileUrl] = bytes;
            return Tile(tileSize, tileSize, bytes);
          } else {
            return Tile(tileSize, tileSize, Uint8List.fromList([]));
          }
        } catch (e) {
          print('Failed to load tile: $tileUrl, error: $e');
          return Tile(tileSize, tileSize, Uint8List.fromList([]));
        }
      }
    }
  }
}
