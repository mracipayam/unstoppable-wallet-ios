import UIKit
import SnapKit

class DepositAddressCollectionCell: UICollectionViewCell {
    private let qrCodeSideSize: CGFloat = 120

    private let titleView = AlertTitleView(frame: .zero)
    private let separatorView = UIView()

    private let qrCodeImageView = UIImageView()
    private let addressTitleLabel = UILabel()
    private let addressButton = HashView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { maker in
            maker.top.leading.trailing.equalToSuperview()
            maker.height.equalTo(AppTheme.alertTitleHeight)
        }

        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(titleView.snp.bottom)
            maker.height.equalTo(CGFloat.heightOnePixel)
        }

        separatorView.backgroundColor = .cryptoSteel20

        contentView.addSubview(qrCodeImageView)
        qrCodeImageView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(separatorView.snp.bottom).offset(CGFloat.margin4x)
            maker.size.equalTo(qrCodeSideSize)
        }

        qrCodeImageView.backgroundColor = .white
        qrCodeImageView.contentMode = .center
        qrCodeImageView.clipsToBounds = true
        qrCodeImageView.layer.cornerRadius = .cornerRadius4

        contentView.addSubview(addressTitleLabel)
        addressTitleLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(qrCodeImageView.snp.bottom).offset(CGFloat.margin3x)
        }

        addressTitleLabel.font = .appCaption
        addressTitleLabel.textColor = .cryptoGray
        addressTitleLabel.textAlignment = .center

        contentView.addSubview(addressButton)
        addressButton.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(CGFloat.margin4x).priority(.high)
            maker.centerX.equalToSuperview()
            maker.top.equalTo(addressTitleLabel.snp.bottom).offset(CGFloat.margin3x)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(address: AddressItem, onCopy: @escaping () -> (), onClose: (() -> ())?) {
        titleView.bind(
                title: "deposit.receive_coin".localized(address.coin.code), 
                subtitle: address.coin.title,
                image: UIImage(coin: address.coin),
                tintColor: nil,
                onClose: onClose
        )

        addressTitleLabel.text = addressTitle(coin: address.coin)
        addressButton.bind(value: address.address, showExtra: .icon, onTap: onCopy)

        qrCodeImageView.asyncSetImage { UIImage(qrCodeString: address.address, size: self.qrCodeSideSize) }
    }

    private func addressTitle(coin: Coin) -> String {
        switch coin.type {
        case .eos: return "deposit.your_account".localized
        default: return "deposit.your_address".localized
        }
    }

}
