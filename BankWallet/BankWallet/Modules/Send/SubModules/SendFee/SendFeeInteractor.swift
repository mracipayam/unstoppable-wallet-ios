import Foundation

class SendFeeInteractor {
    private let rateManager: IRateManager
    private let currencyManager: ICurrencyManager
    private let feeCoinProvider: IFeeCoinProvider

    init(rateManager: IRateManager, currencyManager: ICurrencyManager, feeCoinProvider: IFeeCoinProvider) {
        self.rateManager = rateManager
        self.currencyManager = currencyManager
        self.feeCoinProvider = feeCoinProvider
    }

}

extension SendFeeInteractor: ISendFeeInteractor {

    var baseCurrency: Currency {
        currencyManager.baseCurrency
    }

    func nonExpiredRateValue(coinCode: CoinCode, currencyCode: String) -> Decimal? {
        guard let marketInfo = rateManager.marketInfo(coinCode: coinCode, currencyCode: currencyCode), !marketInfo.expired else {
            return nil
        }
        return marketInfo.rate
    }

    func feeCoin(coin: Coin) -> Coin? {
        feeCoinProvider.feeCoin(coin: coin)
    }

    func feeCoinProtocol(coin: Coin) -> String? {
        feeCoinProvider.feeCoinProtocol(coin: coin)
    }

}
