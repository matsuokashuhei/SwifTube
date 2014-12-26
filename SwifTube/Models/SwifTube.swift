//
//  YouTube.swift
//  YouTubeApp
//
//  Created by matsuosh on 2014/12/16.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import Alamofire

struct SwifTube {
    
    static let secretKey = "AIzaSyBkKOxRcHXfTvMrKHRsWy2cO5dF899agZg"
    
    /**
    ビデオを検索します。
    
    :param: keyword キーワード
    :param: completion ハンドラー
    */
    static func search(#keyword: String, page: Page, completion: (videos: [Video]!, error: NSError!) -> Void) {
        Client.sharedInstance.search(keyword: keyword, page: page, completion: completion)
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
    static func search(#playlistId: String, completion: (videos: [Video]!, error: NSError!) -> Void) {
        Client.sharedInstance.search(playlistId: playlistId, completion: completion)
    }
    
    class Client {
        
        var pageToken: (next: String, prev: String) = (next: "", prev: "")
        
        class var sharedInstance: Client {
            struct Singleton {
                static let instance = Client()
            }
            return Singleton.instance
        }
        
        func search(#keyword: String, completion: (videos: [Video]!, error: NSError!) -> Void) {
            /*
            let parameters = ["q": keyword, "type": "video"]
            search(API: API.Search(parameters)) { (ids, error) in
            if (error == nil) {
            self.find(ids: ids, completion: completion)
            } else {
            completion(videos: nil, error: error)
            }
            }
            */
            search(keyword: keyword, page: .First, completion: completion)
        }
        
        func search(#keyword: String, page: Page, completion: (videos: [Video]!, error: NSError!) -> Void) {
            //let parameters = ["q": keyword, "type": "video"]
            var parameters = ["q": keyword, "type": "video"]
            switch page {
            case .First:
                break
            case .Next:
                parameters.updateValue(pageToken.next, forKey: "pageToken")
            case .Prev:
                parameters.updateValue(pageToken.prev, forKey: "pageToken")
            }
            search(API: API.Search(parameters)) { (ids, error) in
                if (error == nil) {
                    self.find(ids: ids, completion: completion)
                } else {
                    completion(videos: nil, error: error)
                }
            }
        }
        
        func search(#keyword: String, completion: (playlists: [Playlist]!, error: NSError!) -> Void) {
            let parameters = ["q": keyword, "type": "playlist"]
            search(API: API.Search(parameters)) { (ids, error) in
                if (error == nil) {
                    self.find(ids: ids, completion: completion)
                } else {
                    completion(playlists: nil, error: error)
                }
            }
        }
        
        func search(#keyword: String, completion: (channels: [Channel]!, error: NSError!) -> Void) {
            let parameters = ["q": keyword, "type": "channel"]
            search(API: API.Search(parameters)) { (ids, error) in
                if (error == nil) {
                    self.find(ids: ids, completion: completion)
                } else {
                    completion(channels: nil, error: error)
                }
            }
        }
        
        func search(#playlistId: String, completion: (videos: [Video]!, error: NSError!) -> Void) {
            search(API: API.PlaylistItems(playlistId)) { (ids, error) in
                if (error == nil) {
                    self.find(ids: ids, completion: completion)
                } else {
                    completion(videos: nil, error: error)
                }
            }
        }
        
        func search(#channelId: String, completion: (videos: [Video]!, error: NSError!) -> Void) {
            let parameters = ["channelId": channelId, "type": "video"]
            search(API: API.Search(parameters)) { (ids, error) in
                if (error == nil) {
                    self.find(ids: ids, completion: completion)
                } else {
                    completion(videos: nil, error: error)
                }
            }
        }
        
        func search(#channelId: String, completion: (playlists: [Playlist]!, error: NSError!) -> Void) {
            let parameters = ["channelId": channelId, "type": "playlist"]
            search(API: API.Search(parameters)) { (ids, error) in
                if (error == nil) {
                    self.find(ids: ids, completion: completion)
                } else {
                    completion(playlists: nil, error: error)
                }
            }
        }
        
        func search(#API: SwifTube.API, completion: (ids: [String]!, error: NSError!) -> Void) {
            showLoadingIndicator(true)
            Alamofire.request(API).responseJSON() { (_, _, JSON, error) in
                if error == nil {
                    let response = JSON as NSDictionary
                    if let nextPageToken = response["nextPageToken"] as? String {
                        self.pageToken.next = nextPageToken
                    }
                    if let prevPageToken = response["prevPageToken"] as? String {
                        self.pageToken.prev = prevPageToken
                    }
                    let items = response["items"] as [NSDictionary]
                    let ids = items.map { (item: NSDictionary) -> String in
                        return {
                            switch API {
                            case .Search(let parameters):
                                var type = parameters["type"] as String!
                                let id = item["id"] as NSDictionary
                                return id["\(type)Id"] as String
                            case .Videos(_):
                                return item["id"] as String
                            case .Playlists(_):
                                return item["id"] as String
                            case .Channel(_):
                                return item["id"] as String
                            case .PlaylistItems(_):
                                let contentDetails = item["contentDetails"] as NSDictionary
                                return contentDetails["videoId"] as String
                            }
                            }()
                    }
                    self.showLoadingIndicator(false)
                    completion(ids: ids, error: error)
                } else {
                    self.showLoadingIndicator(false)
                    completion(ids: nil, error: error)
                }
            }
        }
        
        func find(#ids: [String], completion: (videos: [Video]!, error: NSError!) -> Void) {
            showLoadingIndicator(true)
            Alamofire.request(API.Videos(ids)).responseJSON() { (_, _, JSON, error) in
                if error == nil {
                    let items = (JSON as NSDictionary).valueForKey("items") as [NSDictionary]
                    let videos = items.map { (item: NSDictionary) -> Video in
                        return Video(item: item)
                    }
                    self.showLoadingIndicator(false)
                    completion(videos: videos, error: nil)
                } else {
                    self.showLoadingIndicator(false)
                    completion(videos: nil, error: error)
                }
            }
        }
        
        func find(#ids: [String], completion: (playlists: [Playlist]!, error: NSError!) -> Void) {
            showLoadingIndicator(true)
            Alamofire.request(API.Playlists(ids)).responseJSON() { (_, _, JSON, error) in
                if error == nil {
                    let items = (JSON as NSDictionary).valueForKey("items") as [NSDictionary]
                    let playlists = items.map { (item: NSDictionary) -> Playlist in
                        return Playlist(item: item)
                    }
                    self.showLoadingIndicator(false)
                    completion(playlists: playlists, error: nil)
                } else {
                    self.showLoadingIndicator(false)
                    completion(playlists: nil, error: error)
                }
            }
        }
        
        func find(#ids: [String], completion: (channels: [Channel]!, error: NSError!) -> Void) {
            showLoadingIndicator(true)
            Alamofire.request(API.Channel(ids)).responseJSON() { (_, _, JSON, error) in
                if error == nil {
                    let items = (JSON as NSDictionary).valueForKey("items") as [NSDictionary]
                    let channels = items.map { (item: NSDictionary) -> Channel in
                        return Channel(item: item)
                    }
                    self.showLoadingIndicator(false)
                    completion(channels: channels, error: nil)
                } else {
                    self.showLoadingIndicator(false)
                    completion(channels: nil, error: error)
                }
            }
        }
        
        private func showLoadingIndicator(show: Bool) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = show
        }
        
    }
    
    enum API: URLRequestConvertible {
        
        static let baseURLString = "https://www.googleapis.com/youtube/v3"
        static let baseParamters = ["key": secretKey, "maxResults": "30"]
        
        case Search(Dictionary<String, String>)
        case Videos([String])
        case Playlists([String])
        case Channel([String])
        case PlaylistItems(String)
        
        var URLRequest: NSURLRequest {
            let (path: String, parameters: [String: AnyObject]) = {
                switch self {
                case .Search(let searchParameters):
                    var parameters = ["part": "snippet"]
                    for (key, value) in API.baseParamters {
                        parameters.updateValue(value, forKey: key)
                    }
                    for (key, value) in searchParameters {
                        parameters.updateValue(value, forKey: key)
                    }
                    return ("/search", parameters)
                case .Videos(let ids):
                    var parameters = ["id": ",".join(ids), "part": "snippet,contentDetails,statistics,topicDetails"]
                    for (key, value) in API.baseParamters {
                        parameters.updateValue(value, forKey: key)
                    }
                    return ("/videos", parameters)
                case .Playlists(let ids):
                    var parameters = ["id": ",".join(ids), "part": "snippet,contentDetails"]
                    for (key, value) in API.baseParamters {
                        parameters.updateValue(value, forKey: key)
                    }
                    return ("/playlists", parameters)
                case .Channel(let ids):
                    var parameters = ["id": ",".join(ids), "part": "snippet,contentDetails,statistics"]
                    for (key, value) in API.baseParamters {
                        parameters.updateValue(value, forKey: key)
                    }
                    return ("/channels", parameters)
                case .PlaylistItems(let playlistId):
                    var parameters = ["part": "snippet,contentDetails", "playlistId": playlistId]
                    for (key, value) in API.baseParamters {
                        parameters.updateValue(value, forKey: key)
                    }
                    return ("/playlistItems", parameters)
                }
                }()
            let URL = NSURL(string: API.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            let encoding = Alamofire.ParameterEncoding.URL
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
    
    enum Page {
        case First
        case Next
        case Prev
    }
}
