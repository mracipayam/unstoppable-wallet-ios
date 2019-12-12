import RxSwift
import DeepDiff

class TransactionsPresenter {
    private let interactor: ITransactionsInteractor
    private let router: ITransactionsRouter
    private let factory: ITransactionViewItemFactory
    private let loader: TransactionsLoader
    private let metaDataSource: TransactionsMetadataDataSource
    private let viewItemLoader: ITransactionViewItemLoader

    weak var view: ITransactionsView?

    init(interactor: ITransactionsInteractor, router: ITransactionsRouter, factory: ITransactionViewItemFactory, loader: TransactionsLoader, metaDataSource: TransactionsMetadataDataSource, viewItemLoader: ITransactionViewItemLoader) {
        self.interactor = interactor
        self.router = router
        self.factory = factory
        self.loader = loader
        self.metaDataSource = metaDataSource
        self.viewItemLoader = viewItemLoader
    }

}

extension TransactionsPresenter: ITransactionViewItemLoaderDelegate {

    func createViewItem(for item: TransactionItem) -> TransactionViewItem {
        let lastBlockHeight = metaDataSource.lastBlockHeight(wallet: item.wallet)
        let threshold = metaDataSource.threshold(wallet: item.wallet)
        let rate = metaDataSource.rate(coin: item.wallet.coin, date: item.record.date)
        return factory.viewItem(fromItem: item, lastBlockHeight: lastBlockHeight, threshold: threshold, rate: rate)
    }

    func reload(with items: [TransactionViewItem], animated: Bool) {
        view?.reload(with: items, animated: animated)
    }

}

extension TransactionsPresenter: ITransactionLoaderDelegate {

    func fetchRecords(fetchDataList: [FetchData], initial: Bool) {
        interactor.fetchRecords(fetchDataList: fetchDataList, initial: initial)
    }

    func reload(with newItems: [TransactionItem], animated: Bool) {
        viewItemLoader.reload(with: newItems, animated: animated)
    }

    func add(items: [TransactionItem]) {
        viewItemLoader.add(items: items)
    }

}

extension TransactionsPresenter: ITransactionsViewDelegate {

    func viewDidLoad() {
        interactor.initialFetch()
    }

    func onFilterSelect(wallet: Wallet?) {
        let wallets = wallet.map { [$0] } ?? []
        interactor.set(selectedWallets: wallets)
    }

    func onBottomReached() {
        DispatchQueue.main.async {
            self.loader.loadNext()
        }
    }

    func onTransactionClick(item: TransactionViewItem) {
        router.openTransactionInfo(viewItem: item)
    }

    func willShow(item: TransactionViewItem) {
        if item.rate == nil {
            interactor.fetchRate(coin: item.wallet.coin, date: item.date)
        }
    }

}

extension TransactionsPresenter: ITransactionsInteractorDelegate {

    func onUpdate(selectedCoins: [Wallet]) {
        loader.set(wallets: selectedCoins)
        loader.loadNext(initial: true)
    }

    func onUpdate(walletsData: [(Wallet, Int, Int?)]) {
        var wallets = [Wallet]()

        for (wallet, threshold, lastBlockHeight) in walletsData {
            wallets.append(wallet)
            metaDataSource.set(threshold: threshold, wallet: wallet)

            if let lastBlockHeight = lastBlockHeight {
                metaDataSource.set(lastBlockHeight: lastBlockHeight, wallet: wallet)
            }
        }

        interactor.fetchLastBlockHeights()

        if wallets.count < 2 {
            view?.show(filters: [])
        } else {
            view?.show(filters: [nil] + wallets)
        }

        loader.handleUpdate(wallets: wallets)
        loader.loadNext(initial: true)
    }

    func onUpdateBaseCurrency() {
        metaDataSource.clearRates()
        viewItemLoader.reloadAll()
    }

    func onUpdate(lastBlockHeight: Int, wallet: Wallet) {
        let oldLastBlockHeight = metaDataSource.lastBlockHeight(wallet: wallet)

        metaDataSource.set(lastBlockHeight: lastBlockHeight, wallet: wallet)

        if let threshold = metaDataSource.threshold(wallet: wallet), let oldLastBlockHeight = oldLastBlockHeight {
            let indexes = loader.itemIndexesForPending(wallet: wallet, blockHeight: oldLastBlockHeight - threshold)

            if !indexes.isEmpty {
                viewItemLoader.reload(indexes: indexes)
            }
        }
    }

    func didUpdate(records: [TransactionRecord], wallet: Wallet) {
        loader.didUpdate(records: records, wallet: wallet)
    }

    func didFetch(rateValue: Decimal, coin: Coin, currency: Currency, date: Date) {
        metaDataSource.set(rate: CurrencyValue(currency: currency, value: rateValue), coin: coin, date: date)

        let indexes = loader.itemIndexes(coin: coin, date: date)

        if !indexes.isEmpty {
            viewItemLoader.reload(indexes: indexes)
        }
    }

    func didFetch(recordsData: [Wallet: [TransactionRecord]], initial: Bool) {
        loader.didFetch(recordsData: recordsData, initial: initial)
    }

    func onConnectionRestore() {
        viewItemLoader.reloadAll()
    }

}
