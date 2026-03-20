/// Returns locale-specific provider banner copy for built-in providers.
///
/// Returns null when the provider does not have a dedicated banner.
String? providerBannerDescription(String providerKey, {required bool isZh}) {
  switch (providerKey.toLowerCase()) {
    case 'tensdaq':
      return isZh
          ? '革命性竞价 AI MaaS 平台，价格由市场供需决定，告别高成本固定定价。'
          : 'A bidding-based AI MaaS platform where pricing is determined by market supply and demand, avoiding high fixed costs.';
    case 'siliconflow':
      return isZh
          ? '已内置硅基流动的免费模型，无需 API Key。若需更强大的模型，请申请并在此配置你自己的 API Key。'
          : 'Built-in free SiliconFlow models are available without an API key. If you need stronger models, request one and configure your own API key here.';
    default:
      return null;
  }
}
