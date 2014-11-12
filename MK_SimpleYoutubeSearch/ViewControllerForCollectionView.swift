//
//  ViewControllerForCollectionView.swift
//  MK_SimpleYoutubeSearch
//
//  Created by MK on 2014/11/12.
//  Copyright (c) 2014年 mk. All rights reserved.
//

import UIKit

class ViewControllerForCollectionView: UIViewController,UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var objects:NSArray! = []

    let API_KEY:String = "AIzaSyCBNx_W4ULaoBnr830KXVTERxnDu91lRu0"
    
    // MARK: - UISearchBar Delegate
    
    //StoryBoard上のSearchBarのdelegateとして呼び出されるメソッド
    //SearchBarで文字を入力し、検索を実行すると呼ばれる
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //searchBarからフォーカスを外す（＝キーボードが隠れる）
        searchBar.resignFirstResponder()
        
        //入力された文字でYoutube検索を行う
        self.searchWord(searchBar.text)
    }
    
    //指定した文字列を引数にYoutubeを検索するメソッド
    func searchWord(text:String){
        
        //SearchBarに入力されている文字列
        println("search text=\(text)")
        
        //URLエンコーディング（文字列エスケープ処理）
        let searchWord:String! = text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        //Youtubeに対して、検索をかける文字列
        let urlString:String = "https://www.googleapis.com/youtube/v3/search?key=\(API_KEY)&q=\(searchWord)&part=id,snippet&maxResults=10&order=viewCount"
        
        //データを読み取るためにNSURL
        let url:NSURL! = NSURL(string:urlString)
        
        
        //JSONデータの取得
        let urlRequest:NSURLRequest = NSURLRequest(URL:url)
        
        //URLに対してNSDataの結果を非同期で取得する
        NSURLConnection.sendAsynchronousRequest(
            urlRequest,
            queue: NSOperationQueue.mainQueue(),
            completionHandler:{(response,jsonData,error) -> Void in
                
                //データが取得できた場合には、JSONを解析してNSDicrionaryに格納
                let dic:NSDictionary = NSJSONSerialization.JSONObjectWithData(
                    jsonData!,
                    options: NSJSONReadingOptions.AllowFragments,
                    error: nil) as NSDictionary
                
                //結果のJSON文字列から必要な箇所だけを取得（itemsのキーだけを取り出す）
                let resultArray:NSArray = dic["items"] as NSArray
                println(resultArray)
                
                //取得したデータの表示
                self.objects = resultArray
                
                //テーブル表示を更新させる（cellの表示が行われる）
                self.collectionView.reloadData()
        })
        
    }
    
    // MARK: - UICollectionView DataSource
    
    //CollectionViewのセル数を決定するメソッド
    //（UICollectionViewDataSourceプロトコル）
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.objects.count
    }
    
    //CollectionViewのセルの表示内容を決定するメソッド
    //（UICollectionViewDataSourceプロトコル）
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //CollectionViewの"Cell"をStoryBoardから取得
        let cell:UICollectionViewCell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        
        //セルに表示するデータを1件取得
        let record:NSDictionary = self.objects[indexPath.row]["snippet"] as NSDictionary
        
        println(record)
        
        //タイトルの取得と表示（JSON内のタイトルの値を取得）
        let titleLabel:UILabel! = cell.viewWithTag(111) as UILabel
        titleLabel.text = record["title"] as String!
        
        
        //サムネイルの取得と表示
        let imageView:UIImageView! = cell.viewWithTag(222) as UIImageView
        
        //（JSONデータから表示したいurlを設定）
        var urlString:NSString = (record["thumbnails"]!["default"] as NSDictionary)["url"] as String
        
        //サムネイル画像をNSDataにダウンロードし、imageViewに設定
        let imageData:NSData = NSData(contentsOfURL:NSURL(string:urlString)!)!
        imageView.image = UIImage(data: imageData)
        
        return cell
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}