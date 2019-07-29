class AppManager {
    private let accountManager: IAccountManager
    private let walletManager: IWalletManager
    private let adapterManager: IAdapterManager
    private let lockManager: ILockManager
    private let passcodeLockManager: IPasscodeLockManager
    private let biometryManager: IBiometryManager
    private let blurManager: IBlurManager
    private let localStorage: ILocalStorage
    private let secureStorage: ISecureStorage

    init(accountManager: IAccountManager, walletManager: IWalletManager, adapterManager: IAdapterManager, lockManager: ILockManager, passcodeLockManager: IPasscodeLockManager, biometryManager: IBiometryManager, blurManager: IBlurManager, localStorage: ILocalStorage, secureStorage: ISecureStorage) {
        self.accountManager = accountManager
        self.walletManager = walletManager
        self.adapterManager = adapterManager
        self.lockManager = lockManager
        self.passcodeLockManager = passcodeLockManager
        self.biometryManager = biometryManager
        self.blurManager = blurManager
        self.localStorage = localStorage
        self.secureStorage = secureStorage
    }

    private func handleFirstLaunch() {
        if !localStorage.didLaunchOnce {
            try? secureStorage.clear()
            localStorage.didLaunchOnce = true
        }
    }

}

extension AppManager: IAppManager {

    func didFinishLaunching() {
        handleFirstLaunch()

        passcodeLockManager.didFinishLaunching()
        accountManager.preloadAccounts()
        walletManager.preloadWallets()
        adapterManager.preloadAdapters()
        biometryManager.refresh()
    }

    func willResignActive() {
        blurManager.willResignActive()
    }

    func didBecomeActive() {
        blurManager.didBecomeActive()
    }

    func didEnterBackground() {
        lockManager.didEnterBackground()
    }

    func willEnterForeground() {
        passcodeLockManager.willEnterForeground()
        lockManager.willEnterForeground()
        adapterManager.refresh()
        biometryManager.refresh()
    }

}