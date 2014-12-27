//
//  YouTube.swift
//  YouTubeApp
//
//  Created by matsuosh on 2014/12/16.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import Alamofire

struct SwifTube {
    
    
    /**
    ビデオを検索します。
    
    :param: keyword キーワード
    :param: completion ハンドラー
    */
    static func search(#keyword: String, completion: (videos: [Video]!, error: NSError!) -> Void) {
        Client.sharedInstance.search(keyword: keyword, completion: completion)
    }
    
    /**
    プレイリストを検索します。
    
    :param: keyword キーワード
    :param: completion ハンドラー
    */
    static func search(#keyword: String, completion: (playlists: [Playlist]!, error: NSError!) -> Void) {
        Client.sharedInstance.search(keyword: keyword, completion: completion)
    }
    
    /**
    チャンネルを検索します。
    
    :param: keyword キーワード
    :param: completion ハンドラー
    */
    static func search(#keyword: String, completion: (channels: [Channel]!, error: NSError!) -> Void) {
        Client.sharedInstance.search(keyword: keyword, completion: completion)
    }
    
    /**
    チャンネルのビデオを検索します。
    
    :param: channelId チャンネルID
    :param: completion ハンドラー
    */
    static func search(#channelId: String, completion: (videos: [Video]!, error: NSError!) -> Void) {
        Client.sharedInstance.search(channelId: channelId, completion: completion)
    }
    
    /**
    チャンネルのプレイリストを検索します。
    
    :param: channelId チャンネルのID
    :param: completion ハンドラー
    */
    static func search(#channelId: String, completion: (playlists: [Playlist]!, error: NSError!) -> Void) {
        Client.sharedInstance.search(channelId: channelId, completion: completion)
    }
    
    /**
    プレイリストのビデオを検索します。
    
    :param: playlistId プレイリストのID
    :param: completion ハンドラー
    */
    static func playlistItems(#id: String, completion: (videos: [Video]!, error: NSError!) -> Void) {
        Client.sharedInstance.playlistItems(id: id, completion: completion)
    }

    enum Page {
        case First
        case Next
        case Prev
        func token(tokens: (next: String, prev: String)) -> String {
            switch self {
            case .First:
                return ""
            case .Next:
                return tokens.next
            case .Prev:
                return tokens.prev
            }
        }
    }

    class Client {
        
        var tokens: (next: String, prev: String) = (next: "", prev: "")
        
        class var sharedInstance: Client {
            struct Singleton {
                static let instance = Client()
            }
            return Singleton.instance
        }

        /*
        func search(#keyword: String, completion: (videos: [Video]!, error: NSError!) -> Void) {
            search(keyword: keyword, page: .First, completion: completion)
        }
        
        func search(#keyword: String, page: Page, completion: (videos: [Video]!, error: NSError!) -> Void) {
            var parameters = ["q": keyword, "type": "video"]
            switch page {
            case .First:
                break
            case .Next:
                parameters.updateValue(pageToken.next, forKey: "pageToken")
            case .Prev:
                parameters.updateValue(pageToken.prev, forKey: "pageToken")
            }
            search(parameters: parameters, completion)
        }
        */
        func search(#keyword: String, completion: (videos: [Video]!, error: NSError!) -> Void) {
            search(keyword: keyword, page: .First, completion: completion)
        }
        func search(#keyword: String, page: Page, completion: (videos: [Video]!, error: NSError!) -> Void) {
            let parameters = ["q": keyword, "type": "video", "pageToken": page.token(tokens)]
            search(parameters: parameters, completion: completion)
        }

        func search(#keyword: String, completion: (playlists: [Playlist]!, error: NSError!) -> Void) {
            search(keyword: keyword, page: .First, completion: completion)
        }
        
        func search(#keyword: String, page: Page, completion: (playlists: [Playlist]!, error: NSError!) -> Void) {
            let parameters = ["q": keyword, "type": "playlist", "order": "viewCount", "page": page.token(tokens)]
            search(parameters: parameters, completion: completion)
        }
    
        func search(#keyword: String, completion: (channels: [Channel]!, error: NSError!) -> Void) {
            search(keyword: keyword, page: .First, completion: completion)
        }

        func search(#keyword: String, page: Page, completion: (channels: [Channel]!, error: NSError!) -> Void) {
            let parameters = ["q": keyword, "type": "channel", "order": "viewCount", "page": page.token(tokens)]
            search(parameters: parameters, completion: completion)
        }

        func search(#channelId: String, completion: (videos: [Video]!, error: NSError!) -> Void) {
            search(channelId: channelId, page: .First, completion: completion)
        }

        func search(#channelId: String, page: Page, completion: (videos: [Video]!, error: NSError!) -> Void) {
            let parameters = ["channelId": channelId, "type": "video", "page": page.token(tokens)]
            search(parameters: parameters, completion: completion)
        }

        func search(#channelId: String, completion: (playlists: [Playlist]!, error: NSError!) -> Void) {
            search(channelId: channelId, page: .First, completion: completion)
        }

        func search(#channelId: String, page: Page, completion: (playlists: [Playlist]!, error: NSError!) -> Void) {
            let parameters = ["channelId": channelId, "type": "playlist", "page": page.token(tokens)]
            search(parameters: parameters, completion: completion)
        }

        func playlistItems<T: APICaller>(#id: String, completion: (items: [T]!, error: NSError!) -> Void) {
            showLoadingIndicator(true)
            Alamofire.request(API.PlaylistItems(id: id)).responseJSON { (_, _, JSON, error) -> Void in
                if let JSON = JSON as? NSDictionary {
                    let objects = JSON["items"] as [NSDictionary]
                    let ids = objects.map { (object: NSDictionary) -> String in
                        let contentDetails = object["contentDetails"] as NSDictionary
                        return contentDetails["videoId"] as String
                    }
                    self.showLoadingIndicator(false)
                    self.find(ids: ids, completion: completion)
                } else {
                    self.showLoadingIndicator(false)
                    completion(items: nil, error: error)
                    
                }
            }
        }

        func search<T: APICaller>(#parameters: [String: String], completion: (items: [T]!, error: NSError!) -> Void) {
            showLoadingIndicator(true)
            Alamofire.request(API.Search(conditions: parameters)).responseJSON { (_, _, JSON, error) -> Void in
                if let JSON = JSON as? NSDictionary {
                    let type = parameters["type"] as String!
                    let objects = JSON["items"] as [NSDictionary]
                    let ids = objects.map { (object: NSDictionary) -> String in
                        let id = object["id"] as NSDictionary
                        return id["\(type)Id"] as String
                    }
                    self.showLoadingIndicator(false)
                    self.find(ids: ids, completion: completion)
                } else {
                    self.showLoadingIndicator(false)
                    completion(items: nil, error: error)
                }
            }
        }

        func find<T: APICaller>(#ids: [String], completion: (items: [T]!, error: NSError!) -> Void) {
            showLoadingIndicator(true)
            Alamofire.request(T.callAPI(ids)).responseJSON() { (_, _, JSON, error) in
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

        private func showLoadingIndicator(show: Bool) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = show
        }
        
    }

}
