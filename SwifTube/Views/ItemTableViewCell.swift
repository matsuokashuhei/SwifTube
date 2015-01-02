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
    
}

class VideoTableViewCell: ItemTableTableViewCell {

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    
    func configure(item: SwifTube.Video) {
        super.configure(item)
        durationLabel.text = item.duration
        channelTitle.text = item.channelTitle
        viewCountLabel.text = "\(item.viewCount) views"
    }
}

class PlaylistTableViewCell: ItemTableTableViewCell {
    
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    
    func configure(item: SwifTube.Playlist) {
        super.configure(item)
        channelTitle.text = item.channelTitle
        if let itemCount = item.itemCount {
            itemCountLabel.text = "\(itemCount) videos"
        } else {
            itemCountLabel.text = ""
        }
    }
}

class ChannelTableViewCell: ItemTableTableViewCell {
    
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    
    func configure(item: SwifTube.Channel) {
        super.configure(item)
        if let viewCount = item.viewCount {
            viewCountLabel.text = "\(viewCount) views"
        } else {
            viewCountLabel.text = ""
        }
        if let videoCount = item.videoCount {
            videoCountLabel.text = "\(videoCount) videos"
        } else {
            videoCountLabel.text = ""
        }
    }
}
