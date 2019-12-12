import UIKit

class TransactionsRouter {
    weak var viewController: UIViewController?
}

extension TransactionsRouter: ITransactionsRouter {

    func openTransactionInfo(viewItem: TransactionViewItem) {
        viewController?.present(TransactionInfoRouter.module(viewItem: viewItem), animated: true)
    }

}

extension TransactionsRouter {

    static func module() -> UIViewController {
        let dataSource = TransactionRecordDataSource(poolRepo: TransactionRecordPoolRepo(), itemsDataSource: TransactionItemDataSource(), factory: TransactionItemFactory())
        let loader = TransactionsLoader(dataSource: dataSource)
        let transactionViewItemLoader = TransactionViewItemLoader(state: TransactionViewItemLoaderState(), differ: Differ())

        let router = TransactionsRouter()
        let interactor = TransactionsInteractor(walletManager: App.shared.walletManager, adapterManager: App.shared.adapterManager, currencyManager: App.shared.currencyManager, rateManager: App.shared.rateManager, reachabilityManager: App.shared.reachabilityManager)
        let presenter = TransactionsPresenter(interactor: interactor, router: router, factory: TransactionViewItemFactory(feeCoinProvider: App.shared.feeCoinProvider), loader: loader, metaDataSource: TransactionsMetadataDataSource(), viewItemLoader: transactionViewItemLoader)
        let viewController = TransactionsViewController(delegate: presenter, differ: Differ())

        loader.delegate = presenter
        interactor.delegate = presenter
        presenter.view = viewController
        router.viewController = viewController
        transactionViewItemLoader.delegate = presenter

        return viewController
    }

}
