/// Copyright (c) 1 Reiwa Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class TwitterLiteViewController: UIViewController {

  var currentTweets: [Tweet] = []
  let fetchLimit = 2

  let initialSearchText = ""
  var searchText: String

  @IBOutlet var tableView: UITableView!

  required init?(coder aDecoder: NSCoder) {
    searchText = initialSearchText
    super.init(coder: aDecoder)
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    searchText = initialSearchText
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupRefreshControl()
    loadTweets(basedOn: searchText)
  }

  private func setupRefreshControl() {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    tableView.refreshControl = refreshControl
  }

  private func loadTweets(basedOn text: String) {
    // Mimic the behaviour of sending backend request
    let range = makeRange(withStartIndex: 0)
    currentTweets = fetchResults(basedOn: text, range: range)
    updateResults()
  }

  private func loadMoreTweets() {
    let range = makeRange(withStartIndex: currentTweets.count)
    currentTweets += fetchResults(basedOn: searchText, range: range)
  }

  private func makeRange(withStartIndex startIndex: Int) -> Range<Int> {
    let endIndex = startIndex + fetchLimit
    return startIndex..<endIndex
  }

  private func fetchResults(basedOn text: String, range: Range<Int>) -> [Tweet] {
    let searchResults = backendTweets.filter { $0.text.contains(text) }
    let fetchResults = Array(searchResults[range.startIndex..<min(range.endIndex, searchResults.count)])
    return fetchResults
  }

  private func updateResults() {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
      self.tableView.refreshControl?.endRefreshing()
      self.tableView.reloadData()
    }
  }

  @objc private func refreshData() {
    loadMoreTweets()
    updateResults()
  }
}

extension TwitterLiteViewController: UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentTweets.count
  }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)
    cell.textLabel?.text = currentTweets[indexPath.row].text
    return cell
  }
}

extension TwitterLiteViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText == initialSearchText {
      currentTweets = []
      tableView.reloadData()
    } else {
      self.searchText = searchText
      loadTweets(basedOn: searchText)
    }
  }
}
