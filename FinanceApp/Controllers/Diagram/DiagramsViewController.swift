//
//  DiagramsViewController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 09.04.2021.
//

import UIKit
import RealmSwift
import FSPagerView
import Charts

class DiagramsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Variables
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var periodButton: UIButton!
    
    let realm = try! Realm()
    var categories: Results<Category>?
    
    var accountToDiagram: Account?
    
    let currency = " rub"
    let numberFormatter = NumberFormatter()
    
    var isSource: Bool = true
    var datePredicates = DatePredicates()
    var appCalculations = AppCalculations()
    
    var periodToDiagram = DatePredicates.Periods.allTime
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.transformer = FSPagerViewTransformer(type: .coverFlow)
        //pagerView.decelerationDistance = FSPagerView.automaticDistance //!
        
        pieChart.delegate = self
        pieChart.holeColor = .clear
        pieChart.holeRadiusPercent = 0.7 //радиус чтобы было колечко
        pieChart.transparentCircleRadiusPercent = 0 //убрать прозрачный круг
       
        // невидимая легенда
        pieChart.legend.textColor = .clear
        pieChart.legend.form = .empty
        
        // установка названий категорий в чарте
        pieChart.entryLabelFont = UIFont.systemFont(ofSize: 17)
        pieChart.entryLabelColor = UIColor(named: "dark_gray")
        //pieChart.drawEntryLabelsEnabled = false //убрать названия слайсов
        appCalculations.periodValues(for: nil)
        balanceLabel.text = String(appCalculations.getBalance().formattedWithSeparator + currency)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCategories()
        customizeChart()
        
        // dynamic width and space
        periodLabel.sizeToFit()
        periodButton.frame.size.width = periodLabel.frame.width + 30
    }

 
// MARK: - IBActions
    @IBAction func chooseInOut(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isSource = true
        }
        else if sender.selectedSegmentIndex == 1 {
            isSource = false
        }
        pieChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInCirc)
        viewWillAppear(true)
    }
    
    @IBAction func choosePeriodPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let allTime = UIAlertAction(title: "All time", style: .default) { [self] (action4) in
            //items = datePredicates.filteredByPeriodItems(for: .allTime)
            periodToDiagram = .allTime
            periodLabel.text = "All time"
            pieChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInCirc)
            viewWillAppear(true)
        }
        let thisMonth = UIAlertAction(title: "This month", style: .default) { [self] (action3) in
            periodToDiagram = .thisMonth
            periodLabel.text = "This month"
            pieChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInCirc)
            viewWillAppear(true)
        }
        let thisWeek = UIAlertAction(title: "This week", style: .default) { [self] (action2) in
            periodToDiagram = .thisWeek
            periodLabel.text = "This week"
            pieChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInCirc)
            viewWillAppear(true)
        }
        let today = UIAlertAction(title: "Today", style: .default) { [self] (action1) in
            periodToDiagram = .today
            periodLabel.text = "Today"
            pieChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInCirc)
            viewWillAppear(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(allTime)
        alert.addAction(thisMonth)
        alert.addAction(thisWeek)
        alert.addAction(today)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView Datasource, TablewView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChartCell", for: indexPath) as!  ChartCell
        cell.categoryNameLabel.text = categories?[indexPath.row].categoryName
        cell.categoryNameLabel.textColor = UIColor(named: (categories?[indexPath.row].color)!)
        var sum = realm.objects(Item.self)
        sum = datePredicates.filteredByPeriodItems(for: periodToDiagram, items: sum)!
        if let account = accountToDiagram {
            sum = sum.filter("account.id = %@", account.id)
        }
        sum = sum.filter("category.id = %@", categories?[indexPath.row].id)
        cell.sumLabel.text = String(sum.map({Int($0.moneyFlow)}).reduce(0, +).formattedWithSeparator + currency)
        return cell
    }
    
    // MARK: - Realm Methods
    func loadCategories() {
        if isSource {
            categories = realm.objects(Category.self).filter("isSource == true").sorted(byKeyPath: "dateCreated", ascending: true)
        }
        else {
            categories = realm.objects(Category.self).filter("isSource == false").sorted(byKeyPath: "dateCreated", ascending: true)
        }
        
        tableView.reloadData()
    }
    
    
}

// MARK: - FSPagerViewDelegate, FSPagerViewDataSource
extension DiagramsViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        let accounts = realm.objects(Account.self).filter("id != %@", K.defaultAccountIfDeleted!.id)
        return accounts.count + 1
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let accounts = realm.objects(Account.self).filter("id != %@", K.defaultAccountIfDeleted!.id).sorted(byKeyPath: "dateCreated", ascending: true)
        
        if index == 0 {
            accountLabel.text = "All accounts"
        }
        else {
            accountLabel.text = accounts[index-1].accountName
        }
        
        cell.contentView.addSubview(pieChart)
        return cell
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        setAccountToDiagram(index: targetIndex)
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        viewWillAppear(true)
    }
    
    func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: FSPagerViewCell, forItemAt index: Int) {
        pieChart.animate(xAxisDuration: 0.8, yAxisDuration: 0.8, easingOption: .easeInCirc)
        viewWillAppear(true)
    }
    
    func setAccountToDiagram(index: Int) {
        let accounts = realm.objects(Account.self).filter("id != %@", K.defaultAccountIfDeleted!.id).sorted(byKeyPath: "dateCreated", ascending: true)
        
        if index == 0 {
            accountToDiagram = nil
        }
        else {
            accountToDiagram = accounts[index-1]
        }
        appCalculations.periodValues(for: accountToDiagram)
        balanceLabel.text = String(appCalculations.getBalance().formattedWithSeparator + currency)
    }
    
}


// MARK: - Extension ChartViewDelegate
extension DiagramsViewController: ChartViewDelegate {
    func customizeChart() {
        let emptyEntry = PieChartDataEntry(value: 1, label: "")
        
        let dataPoints = setArrays().categoryNames
        let values = setArrays().values
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(
                value: values[i],
                label: dataPoints[i])
            if !(values[i] == 0) {
                dataEntries.append(dataEntry)
            }
        }
        
        if dataEntries.isEmpty {
            dataEntries.append(emptyEntry)
        }
        
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        
        pieChartDataSet.colors = pieChartDataSet.entries.contains(emptyEntry) ? ([UIColor.white]) : (setArrays().colors)
        pieChartDataSet.sliceSpace = 3 //белые отступы между слайслами
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        pieChartData.setValueTextColor(pieChartDataSet.entries.contains(emptyEntry) ? (UIColor.clear) : (UIColor(named: "dark_gray")!))
        pieChartData.setValueFont(UIFont.systemFont(ofSize: 17))
        pieChart.data = pieChartData
        
        
    }
    
    
    func setArrays() -> (categoryNames: [String], values: [Double], colors: [UIColor]) {
        var items = realm.objects(Item.self)
        items = datePredicates.filteredByPeriodItems(for: periodToDiagram, items: items)!
        if let account = accountToDiagram {
            items = items.filter("account.id = %@", account.id)
        }

        var categoryNames: [String] = []
        var values: [Double] = []
        var colors = [UIColor]()

        for category in categories! {
            categoryNames.append(category.categoryName)
            var sum: Double = 0.0
            
            for item in items.filter("category.id = %@", category.id) {
                sum += item.moneyFlow
            }
            if sum != 0 {
                colors.append(UIColor(named: category.color)!)
            }
            values.append(sum)
        }
        return (categoryNames, values, colors)
    }
}
