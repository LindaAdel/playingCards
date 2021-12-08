//
//  PlayingCardView.swift
//  PlayingCards
//
//  Created by Linda adel on 11/30/21.
//

import UIKit
@IBDesignable
class PlayingCardView: UIView {
    @IBInspectable
    var rank: Int = 5 {didSet {setNeedsDisplay() ; setNeedsLayout()}}
    @IBInspectable
    var suit : String = "♥️" {didSet {setNeedsDisplay() ; setNeedsLayout()}}
    @IBInspectable
    var isFacedUp : Bool = false {didSet {setNeedsDisplay() ; setNeedsLayout()}}
    var faceCardScale : CGFloat = SizeRatio.faceCardImageSizeToBoundsSize{ didSet {setNeedsDisplay()}}
   @objc func adjustFaceCardScale(byHandlingGestureRecognizer recognizer: UIPinchGestureRecognizer){
    switch recognizer.state {
    case .changed,.ended:
        faceCardScale *= recognizer.scale
        recognizer.scale = 1.0
    default:
        break
    }
        
    }
    private lazy var upperCornerLabel = CreateCornerLabel()
    private lazy var lowerCornerLabel = CreateCornerLabel()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: 16.0)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        if isFacedUp {
            if let faceCardImage = UIImage(named: rankString+suit ,in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            }else {
                drawPips()
            }
        }else{
            if let cardBackImage = UIImage(named: "cardback",in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
                cardBackImage.draw(in: bounds)}
        }
            
    }
            private func CreateCornerLabel() -> UILabel {
                let label = UILabel()
                label.numberOfLines = 0
                addSubview(label)
                return label
            }
            private func configureCornerLabels(_ label : UILabel){
                label.attributedText = cornerString
                label.frame.size = CGSize.zero
                label.sizeToFit()
                label.isHidden = !isFacedUp
            }
            override func layoutSubviews() {
                super.layoutSubviews()
                configureCornerLabels(upperCornerLabel)
                upperCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
                configureCornerLabels(lowerCornerLabel)
                lowerCornerLabel.transform = CGAffineTransform.identity.rotated(by: .pi)
                lowerCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY).offsetBy(dx: -cornerOffset, dy: -cornerOffset)
                    .offsetBy(dx: -lowerCornerLabel.frame.size.width, dy: -lowerCornerLabel.frame.size.height)
                
            }
            private func centeredAttributtedString(_ string: String , fontSize : CGFloat ) -> NSAttributedString{
                var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
                font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributes : [NSAttributedString.Key : Any] = [
                    .paragraphStyle : paragraphStyle,
                    .font : font
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            private var cornerString : NSAttributedString {
                return centeredAttributtedString("\(rankString)\n\(suit)", fontSize: cornerFontSize)
            }
            private func drawPips()
            {
                let pipsPerRowForRank = [[0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2]]
                
                func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
                    let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0)})
                    let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0)})
                    let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
                    let attemptedPipString = centeredAttributtedString(suit, fontSize: verticalPipRowSpacing)
                    let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
                    let probablyOkayPipString = centeredAttributtedString(suit, fontSize: probablyOkayPipStringFontSize)
                    if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                        return centeredAttributtedString(suit, fontSize: probablyOkayPipStringFontSize /
                                                            (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
                    } else {
                        return probablyOkayPipString
                    }
                }
                
                if pipsPerRowForRank.indices.contains(rank) {
                    let pipsPerRow = pipsPerRowForRank[rank]
                    var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
                    let pipString = createPipString(thatFits: pipRect)
                    let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
                    pipRect.size.height = pipString.size().height
                    pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
                    for pipCount in pipsPerRow {
                        switch pipCount {
                        case 1:
                            pipString.draw(in: pipRect)
                        case 2:
                            pipString.draw(in: pipRect.leftHalf)
                            pipString.draw(in: pipRect.rightHalf)
                        default:
                            break
                        }
                        pipRect.origin.y += pipRowSpacing
                    }
                }
            }
            
        }
        // Extension with simple but useful utilities
        extension PlayingCardView {
            
            // Ratios that determine the card's size
            private struct SizeRatio {
                static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
                static let cornerRadiusToBoundsHeight: CGFloat = 0.06
                static let cornerOffsetToCornerRadius: CGFloat = 0.33
                static let faceCardImageSizeToBoundsSize: CGFloat = 0.95
            }
            
            // Corner radius
            private var cornerRadius: CGFloat {
                return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
            }
            
            // Corner offset
            private var cornerOffset: CGFloat {
                return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
            }
            
            // The font size for the corner text
            private var cornerFontSize: CGFloat {
                return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
            }
            
            // Get the string-representation of the current rank
            private var rankString: String {
                switch rank {
                case 1: return "A"
                case 2...10: return String(rank)
                case 11: return "J"
                case 12: return "Q"
                case 13: return "K"
                default: return "?"
                }
            }
        }
        
        // Extension with simple but useful utilities
        extension CGPoint {
            // Get a new point with the given offset
            func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
                return CGPoint(x: x + dx, y: y + dy)
            }
        }
        
        // Extension with simple but useful utilities
        extension CGRect {
            
            // Zoom rect by given factor
            func zoom(by zoomFactor: CGFloat) -> CGRect {
                let zoomedWidth = size.width * zoomFactor
                let zoomedHeight = size.height * zoomFactor
                let originX = origin.x + (size.width - zoomedWidth) / 2
                let originY = origin.y + (size.height - zoomedHeight) / 2
                return CGRect(origin: CGPoint(x: originX,y: originY) , size: CGSize(width: zoomedWidth, height: zoomedHeight))
            }
            
            // Get the left half of the rect
            var leftHalf: CGRect {
                let width = size.width / 2
                return CGRect(origin: origin, size: CGSize(width: width, height: size.height))
            }
            
            // Get the right half of the rect
            var rightHalf: CGRect {
                let width = size.width / 2
                return CGRect(origin: CGPoint(x: origin.x + width, y: origin.y), size: CGSize(width: width, height: size.height))
            }
        }

