//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Dmitrii Seitsman on 01.03.2025.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    static let reuseIdentifier = "ImagesListCell"
    
}
