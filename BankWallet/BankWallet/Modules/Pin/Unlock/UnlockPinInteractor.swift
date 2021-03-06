import Foundation

class UnlockPinInteractor {
    weak var delegate: IUnlockPinInteractorDelegate?

    private let pinManager: IPinManager
    private let biometricManager: IBiometricManager
    private let lockoutManager: ILockoutManager
    private let secureStorage: ISecureStorage
    private var timer: IOneTimeTimer

    init(pinManager: IPinManager, biometricManager: IBiometricManager, lockoutManager: ILockoutManager, timer: IOneTimeTimer, secureStorage: ISecureStorage) {
        self.pinManager = pinManager
        self.biometricManager = biometricManager
        self.lockoutManager = lockoutManager
        self.secureStorage = secureStorage
        self.timer = timer
        self.timer.delegate = self
    }

}

extension UnlockPinInteractor: IUnlockPinInteractor {

    var failedAttempts: Int {
        return secureStorage.unlockAttempts ?? 0
    }

    func updateLockoutState() {
        let state = lockoutManager.currentState
        delegate?.update(lockoutState: state)

        if case .locked(let till) = state {
            timer.schedule(date: till)
        }
    }

    func unlock(with pin: String) -> Bool {
        guard pinManager.validate(pin: pin) else {
            lockoutManager.didFailUnlock()

            updateLockoutState()

            return false
        }

        lockoutManager.dropFailedAttempts()
        return true
    }

    func biometricUnlock() {
        if pinManager.biometryEnabled {
            biometricManager.validate(reason: "biometric_usage_reason")
        } else {
            delegate?.didFailBiometricUnlock()
        }
    }

}

extension UnlockPinInteractor: BiometricManagerDelegate {

    func didValidate() {
        delegate?.didBiometricUnlock()
    }

    func didFailToValidate() {
        delegate?.didFailBiometricUnlock()
    }

}

extension UnlockPinInteractor: IPeriodicTimerDelegate {

    func onFire() {
        updateLockoutState()
    }

}