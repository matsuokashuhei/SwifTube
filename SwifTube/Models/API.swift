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
        
        case Search(parameters: [String: String])
        case Videos(ids: [String])
        case Playlists(ids: [String])
        case Channels(ids: [String])
        case PlaylistItems(parameters: [String: String])

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

        private static let secretKey = "AIzaSyBkKOxRcHXfTvMrKHRsWy2cO5dF899agZg"
        private var baseParameters: [String: String] {
            get {
                var baseParamters = ["key": API.secretKey, "maxResults": "25"]
                switch self {
                case .Search(_):
                    baseParamters.updateValue("snippet", forKey: "part")
                case .Videos(_):
                    baseParamters.updateValue("snippet,contentDetails,statistics", forKey: "part")
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
    
        private static let baseURLString = "https://www.googleapis.com/youtube/v3"
        var URLRequest: NSURLRequest {
            let (path: String, parameters: [String: AnyObject]) = {
                var requestParameters = self.baseParameters
                switch self {
                case .Search(let searchParameters):
                    for (key, value) in searchParameters as [String: String] {
                        requestParameters.updateValue(value, forKey: key)
                    }
                case .Videos(let ids):
                    requestParameters.updateValue(",".join(ids), forKey: "id")
                case .Playlists(let ids):
                    requestParameters.updateValue(",".join(ids), forKey: "id")
                case .Channels(let ids):
                    requestParameters.updateValue(",".join(ids), forKey: "id")
                case .PlaylistItems(let searchParameters):
                    for (key, value) in searchParameters as [String: String] {
                        requestParameters.updateValue(value, forKey: key)
                    }
                }
                return (self.path, requestParameters)
            }()
            let URL = NSURL(string: API.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            let encoding = Alamofire.ParameterEncoding.URL
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
}