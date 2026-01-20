class KKMResource {
  final String title;
  final String videoUrl;
  final String description;
  final String iconAsset; // Optional locally, but we'll use Icons for now

  KKMResource({
    required this.title,
    required this.videoUrl,
    required this.description,
    this.iconAsset = '',
  });
}

class KKMRepository {
  // Mapping keywords to resources
  static KKMResource? getResource(String medicineName, String? genericName) {
    final searchTerms =
        [medicineName, genericName ?? ''].join(' ').toLowerCase();

    // INSULIN
    if (searchTerms.contains('insulin') ||
        searchTerms.contains('novomix') ||
        searchTerms.contains('lantus') ||
        searchTerms.contains('actrapid') ||
        searchTerms.contains('humalog') ||
        searchTerms.contains('penfill')) {
      return KKMResource(
        title: 'Cara Penggunaan Pen Insulin (KKM)',
        videoUrl:
            'https://www.youtube.com/watch?v=s5W5v7qJwOo', // Example common edu video
        description:
            'Panduan langkah demi langkah penggunaan pen insulin yang betul mengikut standard KKM.',
      );
    }

    // INHALER (MDI/DPI)
    if (searchTerms.contains('inhaler') ||
        searchTerms.contains('ventolin') ||
        searchTerms.contains('seretide') ||
        searchTerms.contains('symbicort') ||
        searchTerms.contains('spiriva') ||
        searchTerms.contains('puffer')) {
      return KKMResource(
        title: 'Teknik Penggunaan Inhaler',
        videoUrl:
            'https://www.youtube.com/results?search_query=cara+guna+inhaler+kkm', // Search query is safer for specific types
        description:
            'Pastikan teknik sedutan inhaler anda betul untuk keberkesanan ubat yang optimum.',
      );
    }

    // WARFARIN
    if (searchTerms.contains('warfarin') || searchTerms.contains('coumadin')) {
      return KKMResource(
        title: 'Panduan Pengambilan Warfarin',
        videoUrl:
            'https://www.youtube.com/results?search_query=kkm+warfarin+counseling',
        description:
            'Maklumat kritikal mengenai diet, dos, dan tanda-tanda pendarahan bagi pesakit Warfarin.',
      );
    }

    // NASAL SPRAY
    if (searchTerms.contains('nasal') ||
        searchTerms.contains('spray') ||
        searchTerms.contains('avamys')) {
      return KKMResource(
          title: 'Cara Guna Semburan Hidung',
          videoUrl:
              'https://www.youtube.com/results?search_query=cara+guna+nasal+spray+kkm',
          description:
              'Teknik semburan hidung yang betul untuk mengelakkan kesan sampingan.');
    }

    return null;
  }
}
