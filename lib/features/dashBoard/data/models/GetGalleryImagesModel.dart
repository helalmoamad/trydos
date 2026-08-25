// lib/features/dashBoard/data/models/get_gallery_images_model.dart

class GetGalleryImagesModel {
  final List<GalleryImageModel> images;
  final GalleryMeta? meta;

  GetGalleryImagesModel({required this.images, this.meta});

  factory GetGalleryImagesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    // قراءة متسامحة كما يذكر الدوكيومنت: images at data.images / data.data / data
    dynamic rawImages;
    if (data is Map<String, dynamic>) {
      rawImages = data['images'] ?? data['data'];
      if (rawImages == null && data.values.any((v) => v is List)) {
        rawImages = data.values.firstWhere((v) => v is List, orElse: () => []);
      }
    } else if (data is List) {
      rawImages = data;
    }

    final imagesList = (rawImages as List? ?? [])
        .map((e) => GalleryImageModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final metaJson = data is Map<String, dynamic> ? data['meta'] : null;

    return GetGalleryImagesModel(
      images: imagesList,
      meta: metaJson != null ? GalleryMeta.fromJson(metaJson) : null,
    );
  }
}

class GalleryImageModel {
  final int id;
  final String? url;
  final String? name;

  GalleryImageModel({required this.id, this.url, this.name});

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    return GalleryImageModel(
      id: json['id'] as int,
      url: json['url'] ?? json['path'],
      name: json['name'] ?? json['file_name'],
    );
  }
}

class GalleryMeta {
  final int currentPage;
  final int lastPage;
  final int total;

  GalleryMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory GalleryMeta.fromJson(Map<String, dynamic> json) {
    return GalleryMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}