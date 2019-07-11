class BackupConfirmationPresenter: IBackupConfirmationPresenter {
    private static let confirmationWordsCount = 2

    weak var view: IBackupConfirmationView?

    private let interactor: IBackupConfirmationInteractor
    private let router: IBackupConfirmationRouter

    private let words: [String]

    private(set) var indexes = [Int]()

    init(interactor: IBackupConfirmationInteractor, router: IBackupConfirmationRouter, words: [String]) {
        self.interactor = interactor
        self.router = router
        self.words = words
    }

}

extension BackupConfirmationPresenter: IBackupConfirmationViewDelegate {

    func generateNewIndexes() {
        indexes = interactor.fetchConfirmationIndexes(max: words.count, count: BackupConfirmationPresenter.confirmationWordsCount)
    }

    func validateDidClick(confirmationWords: [String]) {
        do {
            try interactor.validate(words: words, confirmationIndexes: indexes, confirmationWords: confirmationWords)
            router.notifyDidValidate()
        } catch {
            view?.showValidation(error: error)
        }
    }

}

extension BackupConfirmationPresenter: IBackupConfirmationInteractorDelegate {

    func onBecomeActive() {
        view?.onBecomeActive()
    }

}