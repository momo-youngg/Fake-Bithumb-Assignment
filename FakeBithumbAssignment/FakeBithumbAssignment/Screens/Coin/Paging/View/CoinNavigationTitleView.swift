//
//  CoinNavigationTitleView.swift
//  FakeBithumbAssignment
//
//  Created by 박예빈 on 2022/02/26.
//

import UIKit

import SnapKit
import Then

final class CoinNavigationTitleView: UIView {
    
    // MARK: - Instance Property
    
    let coinLabel = UILabel().then {
        $0.text = "비트코인"
        $0.font = .preferredFont(forTextStyle: .caption2)
    }
    
    let subCoinLabel = UILabel().then {
        $0.text = "BTC/KRW"
        $0.font = UIFont.systemFont(ofSize: 5)
        $0.textColor = .gray
    }
    
    
    // MARK: - Life Cycle func
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.render()
        self.configUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // MARK: - custom func
    
    private func render() {
        self.addSubViews([coinLabel, subCoinLabel])
        
        self.coinLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(self)
        }
        
        self.subCoinLabel.snp.makeConstraints { make in
            make.top.equalTo(coinLabel)
            make.leading.trailing.bottom.equalTo(self)
        }
    }
    
    private func configUI() {
        
    }
}
