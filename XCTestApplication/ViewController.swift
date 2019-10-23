//
//  ViewController.swift
//  XCTestApplication-Swift
//
//  Created by Ilham Andrian on 10/21/19.
//

import UIKit
import XCTest
import Foundation

enum TestStatus {
    case none
    case loading
    case fail
    case pass
}

struct TestItem {
    var name : String
    var result : Bool
    var description : String
    var status : TestStatus
}

struct TestSection {
    var name : String
    var items : [TestItem]
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XCTestObservation {

    @IBOutlet weak var stopTestButton: UIBarButtonItem!
    @IBOutlet weak var runTestButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var totalTestFailLabel: UILabel!
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    let suite = XCTestSuite.default
    var totalTest : Int = 0
    var totalFailTest : Int = 0
    var totalDuration : Double = 0.0

    var testItems : Dictionary<String, [TestItem]> = Dictionary.init()
    var testSections = [TestSection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let observationCenter = XCTestObservationCenter.shared
        observationCenter.addTestObserver(self)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.color = .gray
        tableView.backgroundView = activityIndicatorView
        
        self.navigationController?.navigationBar.topItem?.title = "System Test"
    }
    
    // MARK: UIViewController
    
    @IBAction func onStop(_ sender: Any) {
        // TODO: Stop the tests
    }
    
    @IBAction func onRun(_ sender: Any) {
        tableView.allowsSelection = false
        
        let testSuiteRunner = XCTestSuite.init(name: "RunAll-TestSuiteRunner")
        let testClassess = self.subClass(of: XCTestCase.self)
        for testClass in testClassess {
            let testSuite = XCTestSuite.init(forTestCaseClass: testClass)
            testSuiteRunner.addTest(testSuite)
        }

        let observationCenter = XCTestObservationCenter.shared
        observationCenter.addTestObserver(self)

        testSuiteRunner.run()

        DispatchQueue.main.async {
            self.totalTestFailLabel.text = "Failed : \(self.totalFailTest) of \(self.totalTest) tests"
            self.totalDurationLabel.text = "Duration : \(Double(round(1000 * self.totalDuration)/1000))s"
            self.tableView.allowsSelection = true
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(testSections.count == 0) {
            activityIndicatorView.startAnimating()
            tableView.separatorStyle = .none
            
            loadTestItem()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Execute test per click
        let testClassName = testSections[indexPath.section].name
        let testMethodName = testSections[indexPath.section].items[indexPath.row].name
        
        // Check if the class is Obj-C or Swift
        var testClass = NSClassFromString(testClassName)
        if(testClass == nil) {
            let applicationName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            testClass = NSClassFromString(applicationName + "." + testClassName)
        }
        
        let testSuite = XCTestSuite.init(forTestCaseClass: testClass!)
        let testSuiteRunner = XCTestSuite.init(name: "RunOne-TestSuiteRunner")
        
        for test in testSuite.tests {
            if(test.name.components(separatedBy: " ")[1].components(separatedBy: "]")[0] ==  testMethodName) {
                testSuiteRunner.addTest(test)
            }
        }
        
        let observationCenter = XCTestObservationCenter.shared
        observationCenter.addTestObserver(self)
        
        testSuiteRunner.run()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testSections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return testSections[section].name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return testSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Table View Cell", for: indexPath)
                
        let section = testSections[indexPath.section]
        let item = section.items[indexPath.row]
        let description = item.result == true ? "" : "Reason : " + item.description

        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = description
        
        let activityIndicatorCellView = UIActivityIndicatorView.init(style: .medium)
        activityIndicatorCellView.color = .gray
        
        let imageView: UIImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 20, height: 20))
        switch item.status {
        case .none:
            imageView.image = UIImage(systemName:"xmark.circle")
            imageView.setImageColor(color: UIColor.gray)
            cell.accessoryView = imageView
            break
        case .fail:
            activityIndicatorCellView.stopAnimating()
            cell.accessoryView = nil
            imageView.image = UIImage(systemName:"xmark.circle")
            imageView.setImageColor(color: UIColor.red)
            cell.accessoryView = imageView
            break
        case .pass:
            activityIndicatorCellView.stopAnimating()
            cell.accessoryView = nil
            imageView.image = UIImage(systemName:"checkmark.circle")
            imageView.setImageColor(color: UIColor.green)
            cell.accessoryView = imageView
            break
        case .loading:
            activityIndicatorCellView.startAnimating()
            cell.accessoryView = activityIndicatorCellView
            break
        }
        
        return cell
    }
    
    // MARK: XCTestObservation
    
    func testCaseWillStart(_ testCase: XCTestCase) {
        DispatchQueue.main.async {
            self.updateRow(test: testCase, description: "executing..", status: .loading)
        }
    }
    
    func testCaseDidFinish(_ testCase: XCTestCase) {
        totalTest += 1
        DispatchQueue.main.async {
            self.updateRow(test: testCase, description: "")
        }
    }
    
    func testCase(_ testCase: XCTestCase,
                  didFailWithDescription description: String,
                  inFile filePath: String?,
                  atLine lineNumber: Int) {
        totalFailTest += 1
        DispatchQueue.main.async {
            self.updateRow(test: testCase, description: description, status: .fail)
        }
    }
    
    // MARK: Private Functions
    
    func loadTestItem() {
        
        // Load tableview items on the background
        DispatchQueue.global(qos: .background).async {
            // List all class that is subclasses of XCTestCase
            let xcTestCaseClasses = self.subClass(of: XCTestCase.self)
            for i in 0 ..< xcTestCaseClasses.count {
                let xcTestSuite = XCTestSuite.init(forTestCaseClass: xcTestCaseClasses[i])
                for test in xcTestSuite.tests {
                    // Separate test class name with method name, example separate from "[Class_Method]" to "Class" and "Method"
                    let testClassName = test.name.components(separatedBy: " ")[0].components(separatedBy: "[")[1]
                    let testMethodName = test.name.components(separatedBy: " ")[1].components(separatedBy: "]")[0]
                    
                    let testItem = TestItem(name: testMethodName,
                                            result: false,
                                            description: "Not yet executed",
                                            status: .none)
                    
                    self.totalTest += 1
                    
                    if (self.testItems[testClassName] == nil) {
                        self.testItems[testClassName] = [testItem]
                    } else {
                        self.testItems[testClassName]?.append(testItem)
                    }
                }
            }
            
            for(key, value) in self.testItems {
                self.testSections.append(TestSection(name: key, items: value))
            }
            
            // Sort the array base on name
            self.testSections.sort(by: { $0.name < $1.name })
            
            // Once the items has been populated then reload the tableview
            OperationQueue.main.addOperation() {
                self.activityIndicatorView.stopAnimating()
                
                self.tableView.separatorStyle = .singleLine
                self.tableView.reloadData()
            }
        }
    }
    
    // Got this code from https://stackoverflow.com/a/55600510
    func subClass<T>(of theClass: T) -> [T] {
        var count: UInt32 = 0, result: [T] = []
        let allClasses = objc_copyClassList(&count)!
        let classPtr = Unmanaged.passUnretained(theClass as AnyObject).toOpaque()

        for n in 0 ..< count {
            let someClass: AnyClass = allClasses[Int(n)]
            guard let someSuperClass = class_getSuperclass(someClass), Unmanaged.passUnretained(someSuperClass as AnyObject).toOpaque() == classPtr else { continue }
            result.append(someClass as! T)
        }

        return result
    }
    
    func updateRow(test: XCTestCase, description: String) {
        updateRow(test: test, description: description, status: test.testRun?.failureCount == 0 ? .pass : .fail)
    }
    
    func updateRow(test: XCTestCase, description: String, status: TestStatus) {
        let className = test.name.components(separatedBy: " ")[0].components(separatedBy: "[")[1]
        let methodName = test.name.components(separatedBy: " ")[1].components(separatedBy: "]")[0]

        let sectionRow = testSections.firstIndex(where: { $0.name == className })
        let itemRow = testSections[sectionRow!].items.firstIndex(where: { $0.name == methodName })
        
        testSections[sectionRow!].items[itemRow!].result = test.testRun!.hasSucceeded
        testSections[sectionRow!].items[itemRow!].status = status
        if(description.count != 0) {
            testSections[sectionRow!].items[itemRow!].description = description
        }
        
        totalDuration += test.testRun!.totalDuration

        let indexPath = IndexPath(item: itemRow!, section: sectionRow!)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
