//
//  PageViewController.swift
//  Study Chinese app
//
//  Created by Kosuke Shigematsu on 5/2/23.
//
import UIKit

var segmentedNumber = 0
var NowNum = 3

class PageViewController: UIPageViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([getFirst()], direction: .forward, animated: true, completion: nil)
        self.dataSource = self

        segmentControl.addTarget(self, action: #selector(segmentControlValueChanged), for: .valueChanged)
        
    }

    @objc func segmentControlValueChanged() {
        segmentedNumber = segmentControl.selectedSegmentIndex
        print(segmentControl.selectedSegmentIndex)
        print("今発行しました",segmentedNumber)
        NowNum = segmentedNumber
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func getFirst() -> FirstViewController {
        return storyboard!.instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
    }

    func getSecond() -> SecondViewController {
        return storyboard!.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
    }

    func getThird() -> ThirdViewController {
        return storyboard!.instantiateViewController(withIdentifier: "ThirdViewController") as! ThirdViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController is ThirdViewController {
            // 3 -> 2
            return getSecond()
        } else if viewController is SecondViewController {
            // 2 -> 1
            return getFirst()
        } else {
            // 1 -> end of the road
            return getThird()
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController is FirstViewController {
            // 1 -> 2
            return getSecond()
        } else if viewController is SecondViewController {
            // 2 -> 3
            return getThird()
        } else {
            // 3 -> end of the road
            return getFirst()
        }
    }
}
