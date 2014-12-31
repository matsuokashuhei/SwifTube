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
    static func search(#parameters: [String: String], completion: (videos: [Video]!, token: PageToken!, error: NSError!) -> Void) {
        Client.sharedInstance.search(parameters: parameters, completion: completion)
    }

    /**
    プレイリストを検索します。
    
    :param: keyword キーワード
    :param: completion ハンドラー
    */
    static func search(#parameters: [String: String], completion: (playlists: [Playlist]!, token: PageToken!, error: NSError!) -> Void) {
        Client.sharedInstance.search(parameters: parameters, completion: completion)
    }
    
    /**
    チャンネルを検索します。
    
    :param: keyword キーワード
    :param: completion ハンドラー
    */
    static func search(#parameters: [String: String], completion: (channels: [Channel]!, token: PageToken!, error: NSError!) -> Void) {
        Client.sharedInstance.search(parameters: parameters, completion: completion)
    }
    
    /**
    プレイリストのビデオを検索します。
    
    :param: playlistId プレイリストのID
    :param: completion ハンドラー
    */
    static func playlistItems(#parameters: [String: String], completion: (videos: [Video]!, token: PageToken!, error: NSError!) -> Void) {
        Client.sharedInstance.playlistItems(parameters: parameters, completion: completion)
    }

    typealias PageToken = (next: String, prev: String)

    class Client {
        
        class var sharedInstance: Client {
            struct Singleton {
                static let instance = Client()
            }
            return Singleton.instance
        }

        func search(#parameters: [String: String], completion: (videos: [Video]!, token: PageToken!, error: NSError!) -> Void) {
            var APIParameters = ["type": "video",]
            for (key, value) in parameters {
                APIParameters.updateValue(value, forKey: key)
            }
            _search(parameters: APIParameters, completion: completion)
        }

        func search(#parameters: [String: String], completion: (playlists: [Playlist]!, token: PageToken!, error: NSError!) -> Void) {
            //var APIParameters = ["type": "playlist", "order": "viewCount"]
            var APIParameters = ["type": "playlist",]
            for (key, value) in parameters {
                APIParameters.updateValue(value, forKey: key)
            }
            _search(parameters: APIParameters, completion: completion)
        }

        func search(#parameters: [String: String], completion: (channels: [Channel]!, token: PageToken!, error: NSError!) -> Void) {
            //var APIParameters = ["type": "channel", "order": "viewCount"]
            var APIParameters = ["type": "channel",]
            for (key, value) in parameters {
                APIParameters.updateValue(value, forKey: key)
            }
            _search(parameters: APIParameters, completion: completion)
        }

        func playlistItems<T: APICaller>(#parameters: [String: String], completion: (items: [T]!, token: PageToken!, error: NSError!) -> Void) {
            if let token = parameters["pageToken"] {
                if token.isEmpty {
                    completion(items: [], token: (next: "", prev: ""), error: nil)
                    return
                }
            }
            showLoadingIndicator(true)
            let request = Alamofire.request(API.PlaylistItems(parameters: parameters))
            debugPrintln(request)
            request.responseJSON { (_, _, JSON, error) -> Void in
                if let JSON = JSON as? NSDictionary {
                    let token = self.extractPageToken(JSON: JSON)
                    let objects = JSON["items"] as [NSDictionary]
                    let ids = objects.map { (object: NSDictionary) -> String in
                        let contentDetails = object["contentDetails"] as NSDictionary
                        return contentDetails["videoId"] as String
                    }
                    self.showLoadingIndicator(false)
                    self.find(ids: ids) { (items: [T]!, error: NSError!) in
                        completion(items: items, token: token, error: error)
                    }
                } else {
                    self.showLoadingIndicator(false)
                    completion(items: nil, token: nil, error: error)
                }
            }
        }

        func _search<T: APICaller>(#parameters: [String: String], completion: (items: [T]!, token: PageToken!, error: NSError!) -> Void) {
            if let token = parameters["pageToken"] {
                if token.isEmpty {
                    completion(items: [], token: (next: "", prev: ""), error: nil)
                    return
                }
            }
            showLoadingIndicator(true)
            let request = Alamofire.request(API.Search(parameters: parameters))
            debugPrintln(request)
            request.responseJSON { (_, _, JSON, error) -> Void in
                if let JSON = JSON as? NSDictionary {
                    let token = self.extractPageToken(JSON: JSON)
                    let type = parameters["type"] as String!
                    let objects = JSON["items"] as [NSDictionary]
                    let ids = objects.map { (object: NSDictionary) -> String in
                        let id = object["id"] as NSDictionary
                        return id["\(type)Id"] as String
                    }
                    self.showLoadingIndicator(false)
                    self.find(ids: ids) { (items: [T]!, error: NSError!) in
                        completion(items: items, token: token, error: error)
                    }
                } else {
                    self.showLoadingIndicator(false)
                    completion(items: nil, token: nil, error: error)
                }
            }
        }

        func find<T: APICaller>(#ids: [String], completion: (items: [T]!, error: NSError!) -> Void) {
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

        private func extractPageToken(#JSON: NSDictionary) -> PageToken {
            var token: PageToken = (next: "", prev: "")
            if let nextPageToken = JSON["nextPageToken"] as? String {
                token.next = nextPageToken
            }
            if let prevPageToken = JSON["prevPageToken"] as? String {
                token.prev = prevPageToken
            }
            return token
        }
    
        private func showLoadingIndicator(show: Bool) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = show
        }
        
    }

}
