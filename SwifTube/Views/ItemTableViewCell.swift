//
//  ItemTableTableViewCell.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/21.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

class ItemTableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(item: SwifTube.Item) {
        titleLabel.text = item.title
        item.thumbnailImage() { (image: UIImage!, error: NSError!) in
            if let image = image {
                self.thumbnailImageView.image = image
            }
        }
    }

    func formatStringFromInt(integer: Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.stringFromNumber(NSNumber(integer: integer))!
    }

}

class VideoTableViewCell: ItemTableTableViewCell {

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    
    func configure(item: SwifTube.Video) {
        super.configure(item)
        durationLabel.text = item.duration
        channelTitle.text = item.channelTitle
        viewCountLabel.text = "\(formatStringFromInt(item.viewCount)) views"
    }
}

class PlaylistTableViewCell: ItemTableTableViewCell {
    
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    
    func configure(item: SwifTube.Playlist) {
        super.configure(item)
        channelTitle.text = item.channelTitle
        if let itemCount = item.itemCount {
            itemCountLabel.text = "\(formatStringFromInt(itemCount)) videos"
        } else {
            itemCountLabel.text = ""
        }
    }
}

class ChannelTableViewCell: ItemTableTableViewCell {
    
    @IBOutlet weak var subscriberCountLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    
    func configure(item: SwifTube.Channel) {
        super.configure(item)
        /*
        if let viewCount = item.viewCount {
            viewCountLabel.text = "\(formatStringFromInt(viewCount)) views"
        } else {
            viewCountLabel.text = ""
        }
        */
        if let subscriberCount = item.subscriberCount {
            subscriberCountLabel.text = "\(formatStringFromInt(subscriberCount)) subscribes"
        } else {
            subscriberCountLabel.text = ""
        }

        if let videoCount = item.videoCount {
            videoCountLabel.text = "\(formatStringFromInt(videoCount)) videos"
        } else {
            videoCountLabel.text = ""
        }
    }
}
