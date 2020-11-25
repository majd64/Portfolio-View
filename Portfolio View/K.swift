//
//  K.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation

struct K{
   static func convertCommasToDots(_ input: String) -> String {
        return String(input.map {
            $0 == "," ? "." : $0
        })
    }
    
    //_ input: Double, symbol: String
    static func convertToMoneyFormat(_ input: Double, currency: String) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        let formattedBalance = "\(K.getCurrencySymbol(currency: currency))\(numberFormatter.string(from: NSNumber(value: input)) ?? "0.00")"
        return formattedBalance
    }
    
    static func convertToCoinPrice(_ input: Double, currency: String) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if input < 1{
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 6
            numberFormatter.minimumSignificantDigits = 3
            numberFormatter.maximumSignificantDigits = 3
            numberFormatter.roundingMode = .halfUp
        }else{
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
        }
        let formattedPrice = "\(K.getCurrencySymbol(currency: currency))\(numberFormatter.string(from: NSNumber(value: input)) ?? "0.00")"
        return formattedPrice
    }
    
    static func getCurrencySymbol(currency: String) -> String{
        for i in currencies{
            if i[0] == currency.uppercased(){
                return i[1]
            }
        }
        return ""
    }
    
    static func getCurrencyName(currency: String) -> String{
        for i in currencies{
            if i[0] == currency.uppercased(){
                return i[2]
            }
        }
        return ""
    }
    
    static let currencies = [
        [ "RUB", "₽", "Russian ruble" ],
        [ "CNH", "", "Chinese yuan (offshore)" ],
        [ "SEK", "kr", "Swedish krona" ],
        [ "SRD", "$", "Surinamese dollar" ],
        [ "IDR", "Rp", "Indonesian rupiah" ],
        [ "NGN", "₦", "Nigerian naira" ],
        [ "OMR", "﷼", "Omani rial" ],
        [ "STD", "", "São tomé and príncipe dobra (pre 2018)" ],
        [ "ETH", "", "Ethereum" ],
        [ "MZN", "MT", "Mozambican metical" ],
        [ "XPF", "", "Cfp franc" ],
        [ "JMD", "J$", "Jamaican dollar" ],
        [ "BBD", "$", "Barbadian dollar" ],
        [ "NPR", "₨", "Nepalese rupee" ],
        [ "ILS", "₪", "Israeli new sheqel" ],
        [ "SAR", "﷼", "Saudi riyal" ],
        [ "PGK", "K", "Papua new guinean kina" ],
        [ "ZEC", "", "Zcash" ],
        [ "GYD", "$", "Guyanaese dollar" ],
        [ "TZS", "", "Tanzanian shilling" ],
        [ "LKR", "₨", "Sri lankan rupee" ],
        [ "HRK", "kn", "Croatian kuna" ],
        [ "XDR", "", "Special drawing rights" ],
        [ "KMF", "", "Comorian franc" ],
        [ "MUR", "₨", "Mauritian rupee" ],
        [ "VEF", "Bs", "Venezuelan bolívar fuerte" ],
        [ "UZS", "лв", "Uzbekistan som" ],
        [ "PEN", "S/.", "Peruvian nuevo sol" ],
        [ "BDT", "Tk", "Bangladeshi taka" ],
        [ "NZD", "$", "New zealand dollar" ],
        [ "KZT", "лв", "Kazakhstani tenge" ],
        [ "SLL", "Le", "Sierra leonean leone" ],
        [ "GGP", "£", "Guernsey pound" ],
        [ "CUC", "$", "Cuban convertible peso" ],
        [ "DKK", "kr", "Danish krone" ],
        [ "BTC", "₿", "Bitcoin" ],
        [ "SVC", "$", "Salvadoran colón" ],
        [ "QTUM", "", "Qtum" ],
        [ "KHR", "៛", "Cambodian riel" ],
        [ "AZN", "₼", "Azerbaijani manat" ],
        [ "CLP", "$", "Chilean peso" ],
        [ "TMT", "", "Turkmenistani manat" ],
        [ "COP", "$", "Colombian peso" ],
        [ "SOS", "S", "Somali shilling" ],
        [ "YER", "﷼", "Yemeni rial" ],
        [ "MKD", "ден", "Macedonian denar" ],
        [ "KYD", "$", "Cayman islands dollar" ],
        [ "BNB", "", "Binance coin" ],
        [ "UYU", "$U", "Uruguayan peso" ],
        [ "UGX", "UGX", "Ugandan shilling" ],
        [ "USDC", "", "Usd coin" ],
        [ "JEP", "£", "Jersey pound" ],
        [ "LRD", "$", "Liberian dollar" ],
        [ "PHP", "₱", "Philippine peso" ],
        [ "KGS", "лв", "Kyrgystani som" ],
        [ "VES", "", "Venezuelan bolívar soberano" ],
        [ "GBP", "£", "British pound sterling" ],
        [ "ANG", "ƒ", "Netherlands antillean guilder" ],
        [ "AUD", "$", "Australian dollar" ],
        [ "ETB", "Br", "Ethiopian birr" ],
        [ "VND", "₫", "Vietnamese dong" ],
        [ "RSD", "Дин.", "Serbian dinar" ],
        [ "JPY", "¥", "Japanese yen" ],
        [ "KES", "KSh", "Kenyan shilling" ],
        [ "GNF", "", "Guinean franc" ],
        [ "HTG", "G", "Haitian gourde" ],
        [ "MDL", "", "Moldovan leu" ],
        [ "ZWL", "$", "Zimbabwean dollar" ],
        [ "CLF", "", "Chilean unit of account (uf)" ],
        [ "RON", "lei", "Romanian leu" ],
        [ "LAK", "₭", "Laotian kip" ],
        [ "MWK", "MK", "Malawian kwacha" ],
        [ "VUV", "VT", "Vanuatu vatu" ],
        [ "IQD", "د.ع", "Iraqi dinar" ],
        [ "PYG", "Gs", "Paraguayan guarani" ],
        [ "JOD", "", "Jordanian dinar" ],
        [ "NIO", "C$", "Nicaraguan córdoba" ],
        [ "XCD", "$", "East caribbean dollar" ],
        [ "BRL", "R$", "Brazilian real" ],
        [ "BWP", "P", "Botswanan pula" ],
        [ "MNT", "₮", "Mongolian tugrik" ],
        [ "TTD", "TT$", "Trinidad and tobago dollar" ],
        [ "USDT", "", "Tether" ],
        [ "IRR", "﷼", "Iranian rial" ],
        [ "GHS", "¢", "Ghanaian cedi" ],
        [ "XAU", "", "Gold ounce" ],
        [ "AOA", "Kz", "Angolan kwanza" ],
        [ "PLN", "zł", "Polish zloty" ],
        [ "SZL", "", "Swazi lilangeni" ],
        [ "FKP", "£", "Falkland islands pound" ],
        [ "XOF", "", "Cfa franc bceao" ],
        [ "PKR", "₨", "Pakistani rupee" ],
        [ "UAH", "₴", "Ukrainian hryvnia" ],
        [ "TRY", "Kr", "Turkish lira" ],
        [ "BOB", "$b", "Bolivian boliviano" ],
        [ "CHF", "CHF", "Swiss franc" ],
        [ "KRW", "", "South korean won" ],
        [ "KWD", "ك", "Kuwaiti dinar" ],
        [ "MVR", "", "Maldivian rufiyaa" ],
        [ "GMD", "", "Gambian dalasi" ],
        [ "DAI", "", "Multi collateral dai" ],
        [ "DOP", "RD$", "Dominican peso" ],
        [ "LYD", "LD", "Libyan dinar" ],
        [ "EUR", "€", "Euro" ],
        [ "LTC", "", "Litecoin" ],
        [ "HUF", "Ft", "Hungarian forint" ],
        [ "BND", "$", "Brunei dollar" ],
        [ "CUP", "₱", "Cuban peso" ],
        [ "HKD", "$", "Hong kong dollar" ],
        [ "DZD", "", "Algerian dinar" ],
        [ "XPT", "", "Platinum ounce" ],
        [ "QAR", "﷼", "Qatari rial" ],
        [ "SGD", "$", "Singapore dollar" ],
        [ "MXN", "$", "Mexican peso" ],
        [ "EOS", "", "Eos" ],
        [ "MRU", "", "Mauritanian ouguiya" ],
        [ "CNY", "¥", "Chinese yuan renminbi" ],
        [ "ERN", "", "Eritrean nakfa" ],
        [ "BAM", "KM", "Bosnia herzegovina convertible mark" ],
        [ "SHP", "£", "Saint helena pound" ],
        [ "MGA", "Ar", "Malagasy ariary" ],
        [ "CAD", "$", "Canadian dollar" ],
        [ "SBD", "$", "Solomon islands dollar" ],
        [ "TWD", "NT$", "New taiwan dollar" ],
        [ "XAF", "", "Cfa franc beac" ],
        [ "INR", "₹", "Indian rupee" ],
        [ "STN", "", "São tomé and príncipe dobra" ],
        [ "BIF", "", "Burundian franc" ],
        [ "MOP", "MOP$", "Macanese pataca" ],
        [ "SDG", "", "Sudanese pound" ],
        [ "CVE", "$", "Cape verdean escudo" ],
        [ "GIP", "£", "Gibraltar pound" ],
        [ "IMP", "£", "Manx pound" ],
        [ "RWF", "", "Rwandan franc" ],
        [ "PAB", "B/.", "Panamanian balboa" ],
        [ "ZMW", "ZK", "Zambian kwacha" ],
        [ "AFN", "؋ ", "Afghan afghani" ],
        [ "AMD", "֏", "Armenian dram" ],
        [ "CRC", "₡", "Costa rican colón" ],
        [ "BCH", "", "Bitcoin cash" ],
        [ "NOK", "kr", "Norwegian krone" ],
        [ "BYN", "Br", "Belarusian ruble" ],
        [ "SYP", "£", "Syrian pound" ],
        [ "DASH", "", "Dash" ],
        [ "DOGE", "", "Dogecoin" ],
        [ "BZD", "BZ$", "Belize dollar" ],
        [ "ARS", "$", "Argentine peso" ],
        [ "NAD", "$", "Namibian dollar" ],
        [ "WST", "$", "Samoan tala" ],
        [ "HNL", "L", "Honduran lempira" ],
        [ "LSL", "", "Lesotho loti" ],
        [ "BGN", "лв", "Bulgarian lev" ],
        [ "HUSD", "", "Husd" ],
        [ "BMD", "$", "Bermudan dollar" ],
        [ "DJF", "$", "Djiboutian franc" ],
        [ "TJS", "", "Tajikistani somoni" ],
        [ "USD", "$", "United states dollar" ],
        [ "SCR", "₨", "Seychellois rupee" ],
        [ "EGP", "£", "Egyptian pound" ],
        [ "GTQ", "Q", "Guatemalan quetzal" ],
        [ "CDF", "", "Congolese franc" ],
        [ "BHD", "BD", "Bahraini dinar" ],
        [ "GEL", "", "Georgian lari" ],
        [ "BTN", "", "Bhutanese ngultrum" ],
        [ "AED", "فلس", "United arab emirates dirham" ],
        [ "CZK", "Kč", "Czech republic koruna" ],
        [ "MRO", "", "Mauritanian ouguiya (pre 2018)" ],
        [ "AWG", "ƒ", "Aruban florin" ],
        [ "TND", "", "Tunisian dinar" ],
        [ "XAG", "", "Silver ounce" ],
        [ "MAD", "", "Moroccan dirham" ],
        [ "MYR", "RM", "Malaysian ringgit" ],
        [ "ISK", "kr", "Icelandic króna" ],
        [ "XPD", "", "Palladium ounce" ],
        [ "ZAR", "R", "South african rand" ],
        [ "LBP", "£", "Lebanese pound" ],
        [ "MMK", "K", "Myanma kyat" ],
        [ "WAVES", "", "Waves" ],
        [ "FJD", "$", "Fijian dollar" ],
        [ "SSP", "", "South sudanese pound" ],
        [ "THB", "฿", "Thai baht" ],
        [ "KPW", "₩", "North korean won" ]
      ]


 
}


//    func getPortfolioBalanceChange24h() -> Double?{
//        var balanceValueChange24h: Double = 0
//        for coin: Coin in coinsArray{
//            var previousTransactionBalance: Double = 0
//            var newTransactionBalance: Double = 0
//            for transaction: Transaction in coin.getTransactions(){
//                let type: String = transaction.getTransactionType()
//                if type == Transaction.typeSent || type == Transaction.typeSold || type == Transaction.typeTransferredFrom{
//
//                    if (NSDate().timeIntervalSince1970 - transaction.getDate() > 86400){
//                        previousTransactionBalance -= transaction.getAmountOfParentCoin()
//                    }else{
//                        newTransactionBalance -= transaction.getAmountOfParentCoin()
//                    }
//                }
//                else if type == Transaction.typeReceived || type == Transaction.typeBought || type == Transaction.typeTransferredTo{
//                    if (NSDate().timeIntervalSince1970 - transaction.getDate() > 86400){
//                        previousTransactionBalance += transaction.getAmountOfParentCoin()
//                    }else{
//                        newTransactionBalance += transaction.getAmountOfParentCoin()
//                    }
//                }
//            }
//            balanceValueChange24h += previousTransactionBalance * coin.getPrice(withRate: preferredCurrency?.getRateUsd() ?? 1) * (1 - (1/(1 + coin.getChangePercent24Hr()))) + newTransactionBalance * coin.getPrice(withRate: preferredCurrency?.getRateUsd() ?? 1)
//        }
//        return balanceValueChange24h
//    }
