//
//  SwifTube.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/16.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import Alamofire

struct SwifTube {

    /**
    ビデオを検索します。
    
    :param: parameters キーワード
    :param: completion ハンドラー
    */
    static func search(#parameters: [String: String], completion: (pageInfo: PageInfo!, videos: [Video]!, error: NSError!) -> Void) {
        Client.sharedInstance.search(parameters: parameters, completion: completion)
    }

    /**
    プレイリストを検索します。
    
    :param: keyword キーワード
    :param: completion ハンドラー
    */
    static func search(#parameters: [String: String], completion: (pageInfo: PageInfo!, playlists: [Playlist]!, error: NSError!) -> Void) {
        Client.sharedInstance.search(parameters: parameters, completion: completion)
    }
    
    /**
    チャンネルを検索します。
    
    :param: keyword キーワード
    :param: completion ハンドラー
    */
    static func search(#parameters: [String: String], completion: (pageInfo: PageInfo!, channels: [Channel]!, error: NSError!) -> Void) {
        Client.sharedInstance.search(parameters: parameters, completion: completion)
    }
    
    /**
    プレイリストのビデオを検索します。
    
    :param: playlistId プレイリストのID
    :param: completion ハンドラー
    */
    static func playlistItems(#parameters: [String: String], completion: (pageInfo: PageInfo!, videos: [Video]!, error: NSError!) -> Void) {
        Client.sharedInstance.playlistItems(parameters: parameters, completion: completion)
    }

    typealias PageInfo = (nextPageToken: String, prevPageToken: String, totalResults: Int, resultsPerPage: Int)

    class Client {
        
        class var sharedInstance: Client {
            struct Singleton {
                static let instance = Client()
            }
            return Singleton.instance
        }

        func search(#parameters: [String: String], completion: (pageInfo: PageInfo!, videos: [Video]!, error: NSError!) -> Void) {
            var APIParameters = ["type": "video",]
            for (key, value) in parameters {
                APIParameters.updateValue(value, forKey: key)
            }
            _search(parameters: APIParameters, completion: completion)
        }

        func search(#parameters: [String: String], completion: (pageInfo: PageInfo!, playlists: [Playlist]!, error: NSError!) -> Void) {
            //var APIParameters = ["type": "playlist", "order": "viewCount"]
            var APIParameters = ["type": "playlist",]
            for (key, value) in parameters {
                APIParameters.updateValue(value, forKey: key)
            }
            _search(parameters: APIParameters, completion: completion)
        }

        func search(#parameters: [String: String], completion: (pageInfo: PageInfo!, channels: [Channel]!, error: NSError!) -> Void) {
            //var APIParameters = ["type": "channel", "order": "viewCount"]
            var APIParameters = ["type": "channel",]
            for (key, value) in parameters {
                APIParameters.updateValue(value, forKey: key)
            }
            _search(parameters: APIParameters, completion: completion)
        }

        func playlistItems<T: APICaller>(#parameters: [String: String], completion: (pageInfo: PageInfo!, items: [T]!, error: NSError!) -> Void) {
            if let token = parameters["pageToken"] {
                if token.isEmpty {
                    completion(pageInfo: pageInfo(), items: [], error: nil)
                    return
                }
            }
            showLoadingIndicator(true)
            let request = Alamofire.request(API.PlaylistItems(parameters: parameters))
            debugPrintln(request)
            request.responseJSON { (_, _, JSON, error) -> Void in
                if let JSON = JSON as? NSDictionary {
                    //let token = self.extractPageToken(JSON: JSON)
                    let pageInfo = self.pageInfo(JSON: JSON)
                    let objects = JSON["items"] as [NSDictionary]
                    let ids = objects.map { (object: NSDictionary) -> String in
                        let contentDetails = object["contentDetails"] as NSDictionary
                        return contentDetails["videoId"] as String
                    }
                    self.showLoadingIndicator(false)
                    self.find(ids: ids) { (items: [T]!, error: NSError!) in
                        completion(pageInfo: pageInfo, items: items, error: error)
                    }
                } else {
                    self.showLoadingIndicator(false)
                    completion(pageInfo: nil, items: nil, error: error)
                }
            }
        }

        private func _search<T: APICaller>(#parameters: [String: String], completion: (pageInfo: PageInfo!, items: [T]!, error: NSError!) -> Void) {
            if let token = parameters["pageToken"] {
                if token.isEmpty {
                    completion(pageInfo: pageInfo(), items: [], error: nil)
                    return
                }
            }
            showLoadingIndicator(true)
            let request = Alamofire.request(API.Search(parameters: parameters))
            debugPrintln(request)
            request.responseJSON { (_, _, JSON, error) -> Void in
                if let JSON = JSON as? NSDictionary {
                    //let token = self.extractPageToken(JSON: JSON)
                    let pageInfo = self.pageInfo(JSON: JSON)
                    let type = parameters["type"] as String!
                    let objects = JSON["items"] as [NSDictionary]
                    let ids = objects.map { (object: NSDictionary) -> String in
                        let id = object["id"] as NSDictionary
                        return id["\(type)Id"] as String
                    }
                    self.showLoadingIndicator(false)
                    self.find(ids: ids) { (items: [T]!, error: NSError!) in
                        //completion(items: items, token: token, error: error)
                        completion(pageInfo: pageInfo, items: items, error: error)
                    }
                } else {
                    self.showLoadingIndicator(false)
                    completion(pageInfo: nil, items: nil, error: error)
                }
            }
        }

        private func find<T: APICaller>(#ids: [String], completion: (items: [T]!, error: NSError!) -> Void) {
            showLoadingIndicator(true)
            let request = Alamofire.request(T.callAPI(ids))
            debugPrintln(request)
            request.responseJSON { (_, _, JSON, error) -> Void in
                if error == nil {
                    let objects = (JSON as NSDictionary).valueForKey("items") as [NSDictionary]
                    let items = objects.map { (object: NSDictionary) -> T in
                        return T(item: object)
                    }
                    self.showLoadingIndicator(false)
                    completion(items: items, error: nil)
                } else {
                    self.showLoadingIndicator(false)
                    completion(items: nil, error: error)
                }
            }
        }

        private func pageInfo() -> PageInfo {
            return (nextPageToken: "", prevPageToken: "", totalResults: 0, resultsPerPage: 0)
        }

        private func pageInfo(#JSON: NSDictionary) -> PageInfo {
            var pageInfo = self.pageInfo()
            if let nextPageToken = JSON["nextPageToken"] as? String {
                pageInfo.nextPageToken = nextPageToken
            }
            if let prevPageToken = JSON["prevPageToken"] as? String {
                pageInfo.prevPageToken = prevPageToken
            }
            pageInfo.totalResults = (JSON["pageInfo"] as NSDictionary)["totalResults"] as Int
            pageInfo.resultsPerPage = (JSON["pageInfo"] as NSDictionary)["resultsPerPage"] as Int
            return pageInfo
        }

        private func showLoadingIndicator(show: Bool) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = show
        }

    }

}
