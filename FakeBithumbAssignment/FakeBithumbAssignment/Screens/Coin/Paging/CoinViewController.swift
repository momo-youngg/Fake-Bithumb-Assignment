//
//  CoinViewController.swift
//  FakeBithumbAssignment
//
//  Created by 박예빈 on 2022/02/23.
//

import UIKit

import SnapKit
import Then

final class CoinViewController: BaseViewController {
    
    // MARK: - Instance Property
    
    let sectionInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    private let headerView = CoinHeaderView()
    
    private let menuCollectionView = UICollectionView(frame: CGRect.zero,
                                                      collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.backgroundColor = .white
        $0.register(cell: CoinMenuCollectionViewCell.self)
    }
    
    private let pageView = UIView().then {
        $0.backgroundColor = .white
    }
    
    
    // MARK: - Life Cycle func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        configUI()
        setDelegations()
        patchHeaderViewData()
    }
    
    override func configUI() {
        super.configUI()
        configStackView()
    }
    
    
    // MARK: - custom func
    
    private func setDelegations() {
        self.menuCollectionView.delegate = self
        self.menuCollectionView.dataSource = self
    }
    
    private func configStackView() {
        let stackView: UIStackView = UIStackView(
            arrangedSubviews: [self.headerView, self.menuCollectionView, self.pageView]
        ).then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.spacing = 1
        }
        
        self.view.addSubview(stackView)
        self.headerView.snp.makeConstraints { (make) in
            make.height.equalTo(90)
        }
        self.menuCollectionView.snp.makeConstraints { (make) in
            make.height.equalTo(35)
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func patchHeaderViewData() {
        self.headerView.patchData(data: CoinHeaderModel(currentPrice: 4559400, fluctate: -1578000, fluctateUpDown: "up", fluctateRate: 3.35))
    }
}
