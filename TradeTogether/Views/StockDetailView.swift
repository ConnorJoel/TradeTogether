//
//  StockDetailView.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import SwiftUI

struct StockDetailView: View {
    @EnvironmentObject var stockVM: StockViewModel
    
    @State var stockTicker: String
    
    var body: some View {
        VStack {
            Text("Quote Data For \(stockTicker)")
                .font(.title3)
                .bold()
                .padding(.vertical, 4.0)
            
            HStack (alignment: .top) {
                VStack (alignment: .leading) {
                    Text("$\(String(stockVM.currentStock.c))")
                        .font(.largeTitle)
                        .bold()
                    Text("\(String(stockVM.currentStock.dp))%")
                        .font(.title)
                        .bold()
                }
                .foregroundColor(setTickerColor(change: String(stockVM.currentStock.dp)))
                .frame(maxWidth: .infinity, alignment: .topLeading)
                HStack {
                    VStack (alignment: .leading) {
                        Text("High:")
                        Text("Low:")
                        Text("Opening:")
                        Text("Prev. Close:")
                        Text("Change:")
                    }
                    .bold()
                    VStack (alignment: .trailing){
                        Text("$\(String(stockVM.currentStock.h))")
                        Text("$\(String(stockVM.currentStock.l))")
                        Text("$\(String(stockVM.currentStock.o))")
                        Text("$\(String(stockVM.currentStock.pc))")
                        Text("$\(String(stockVM.currentStock.d))")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom)
            
            Text("Advanced Data & Other Metrics")
                .font(.title3)
                .bold()
                .padding(.bottom)
            
            HStack {
                HStack (spacing: 0){
                    VStack (alignment: .trailing){
                        Text("Asset Turnover:")
                        Text("Beta:")
                        Text("Dividend Yield:")
                        Text("Ent. Val.:")
                        Text("EPS:")
                        Text("Gros. Margin:")
                        Text("N. Prof. Margin:")
                        Text("Oper. Margin:")
                        Text("P/E:")
                        Text("YTD Daily %:")
                    }
                    .bold()
                    VStack (alignment: .leading) {
                        Text("\(stockVM.currentStockAdvanced.metric.assetTurnoverAnnual ?? 0.00, specifier: "%.2f")")
                        Text("\(stockVM.currentStockAdvanced.metric.beta ?? 0.00, specifier: "%.2f")")
                        Text("\(stockVM.currentStockAdvanced.metric.dividendYieldIndicatedAnnual ?? 0.00, specifier: "%.2f")")
                        Text("\(stockVM.currentStockAdvanced.metric.enterpriseValue ?? 0.00, specifier: "%.2f")")
                        Text("\(stockVM.currentStockAdvanced.metric.epsAnnual ?? 0.00, specifier: "%.2f")")
                        Text("\(stockVM.currentStockAdvanced.metric.grossMarginAnnual ?? 0.00, specifier: "%.2f")")
                        Text("\(stockVM.currentStockAdvanced.metric.netProfitMarginAnnual ?? 0.00, specifier: "%.2f")")
                        Text("\(stockVM.currentStockAdvanced.metric.operatingMarginAnnual ?? 0.00, specifier: "%.2f")")
                        
                        Text("\(stockVM.currentStockAdvanced.metric.peAnnual ?? 0.00, specifier: "%.2f")")
                        Text("\(stockVM.currentStockAdvanced.metric.yearToDatePriceReturnDaily ?? 0.00, specifier: "%.2f")")
                    }
                    .padding(.leading)
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                await stockVM.getData()
                await stockVM.getAdvancedData()
            }
        }
    }
    
    //Function to set the color of watchlist % change tickers
    func setTickerColor(change: String) -> Color {
        if change == "N/A" {
            return Color(.black)
        } else if Double(change)! > 0 {
            return Color("BetterGreen")
        } else if Double(change)! < 0 {
            return Color(.red)
        } else {
            return Color(.black)
        }
    }
}

struct StockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StockDetailView(stockTicker: "AAPL")
            .environmentObject(StockViewModel())
    }
}
