//
//  CardView.swift
//  OnlinePalace
//
//  Created by VishalP on 4/18/25.
//

import SwiftUI


// Define the CardView
struct CardView: View {
    let card: Card
    var isHidden = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(Color.black, lineWidth: Constants.lineWidth)
            if isHidden {
                Image(Constants.backCardImage)
                    .resizable()
                    .scaledToFit()
            } else {
                VStack(alignment: .center) {
                    Text(card.rank)
                        .font(.title)
                        .foregroundColor(card.suit.color)
                    Text(card.suit.symbol)
                        .font(.system(size: Constants.rankSize))
                        .foregroundColor(card.suit.color)
                    
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(width: Constants.cardWidth, height: Constants.cardHeight)
        .preferredColorScheme(.light)
    }
    
    enum Constants {
        static let backCardImage = "cardBack"
        static let cardWidth = 55.0
        static let cardHeight = 80.0
        static let cornerRadius = 10.0
        static let lineWidth = 5.0
        static let rankSize = 30.0
    }
}

// MARK: - Preview
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 10) {
            CardView(card: .init(rank: "K", suit: .diamonds))
            CardView(card: .init(rank: "2", suit: .clubs))
            CardView(card: .init(rank: "2", suit: .clubs),
                     isHidden: true)
        }
    }
}
