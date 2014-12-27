//
//  API.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/28.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import Alamofire

extension SwifTube {

    enum API: URLRequestConvertible {
        
        private static let baseURLString = "https://www.googleapis.com/youtube/v3"
        private static let secretKey = "AIzaSyBkKOxRcHXfTvMrKHRsWy2cO5dF899agZg"
        
        case Search(conditions: [String: String])
        case Videos(ids: [String])
        case Playlists(ids: [String])
        case Channels(ids: [String])
        case PlaylistItems(id: String)

        private var path: String {
            get {
                switch self {
                case .Search(_):
                    return "/search"
                case .Videos(_):
                    return "/videos"
                case .Playlists(_):
                    return "/playlists"
                case .Channels(_):
                    return "/channels"
                case .PlaylistItems(_):
                    return "/playlistItems"
                }
            }
        }
        private var baseParameters: [String: String] {
            get {
                var baseParamters = ["key": API.secretKey, "maxResults": "30"]
                switch self {
                case .Search(_):
                    baseParamters.updateValue("snippet", forKey: "part")
                case .Videos(_):
                    baseParamters.updateValue("snippet,contentDetails,statistics,topicDetails", forKey: "part")
                case .Playlists(_):
                    baseParamters.updateValue("snippet,contentDetails", forKey: "part")
                case .Channels(_):
                    baseParamters.updateValue("snippet,contentDetails,statistics", forKey: "part")
                case .PlaylistItems(_):
                    baseParamters.updateValue("snippet,contentDetails", forKey: "part")
                }
                return  baseParamters
            }
        }
        var URLRequest: NSURLRequest {
            let (path: String, parameters: [String: AnyObject]) = {
                var parameters = self.baseParameters
                switch self {
                case .Search(let conditions):
                    for (key, value) in conditions as [String: String] {
                        parameters.updateValue(value, forKey: key)
                    }
                case .Videos(let ids):
                    parameters.updateValue(",".join(ids), forKey: "id")
                case .Playlists(let ids):
                    parameters.updateValue(",".join(ids), forKey: "id")
                case .Channels(let ids):
                    parameters.updateValue(",".join(ids), forKey: "id")
                case .PlaylistItems(let id):
                    parameters.updateValue(id, forKey: "playlistId")
                }
                return (self.path, parameters)
            }()
            let URL = NSURL(string: API.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            let encoding = Alamofire.ParameterEncoding.URL
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
}