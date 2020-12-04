//
//  K.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation
import UIKit


struct K{
    static let api = "https://www.portfolioview.ca"
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
    
    static func getCurrencyID(currency: String) -> String{
        for i in currencies{
            if i[0] == currency.uppercased(){
                return i[3]
            }
        }
        return ""
    }
    
    static let currencies = [
        [ "BDT", "Tk", "Bangladeshi taka", "bangladeshi-taka" ],
          [ "TZS", "", "Tanzanian shilling", "tanzanian-shilling" ],
          [ "SRD", "$", "Surinamese dollar", "surinamese-dollar" ],
          [ "CNY", "¥", "Chinese yuan renminbi", "chinese-yuan-renminbi" ],
          [ "DKK", "kr", "Danish krone", "danish-krone" ],
          [ "QAR", "﷼", "Qatari rial", "qatari-rial" ],
          [ "SZL", "", "Swazi lilangeni", "swazi-lilangeni" ],
          [ "BBD", "$", "Barbadian dollar", "barbadian-dollar" ],
          [ "DAI", "", "Multi collateral dai", "multi-collateral-dai" ],
          [ "ARS", "$", "Argentine peso", "argentine-peso" ],
          [ "PEN", "S/.", "Peruvian nuevo sol", "peruvian-nuevo-sol" ],
          [ "IDR", "Rp", "Indonesian rupiah", "indonesian-rupiah" ],
          [ "SLL", "Le", "Sierra leonean leone", "sierra-leonean-leone" ],
          [ "LAK", "₭", "Laotian kip", "laotian-kip" ],
          [ "ETB", "Br", "Ethiopian birr", "ethiopian-birr" ],
          [ "TMT", "", "Turkmenistani manat", "turkmenistani-manat" ],
          [ "LYD", "LD", "Libyan dinar", "libyan-dinar" ],
          [ "MRU", "", "Mauritanian ouguiya", "mauritanian-ouguiya" ],
          [ "KGS", "лв", "Kyrgystani som", "kyrgystani-som" ],
          [ "QTUM", "", "Qtum", "qtum" ],
          [ "BNB", "", "Binance coin", "binance-coin" ],
          [ "ZMW", "ZK", "Zambian kwacha", "zambian-kwacha" ],
          [ "CDF", "", "Congolese franc", "congolese-franc" ],
          [ "GHS", "¢", "Ghanaian cedi", "ghanaian-cedi" ],
          [ "CHF", "CHF", "Swiss franc", "swiss-franc" ],
          [ "MZN", "MT", "Mozambican metical", "mozambican-metical" ],
          [ "SBD", "$", "Solomon islands dollar", "solomon-islands-dollar" ],
          [ "BIF", "", "Burundian franc", "burundian-franc" ],
          [ "XAF", "", "Cfa franc beac", "cfa-franc-beac" ],
          [ "HKD", "$", "Hong kong dollar", "hong-kong-dollar" ],
          [ "PGK", "K", "Papua new guinean kina", "papua-new-guinean-kina" ],
          [ "KMF", "", "Comorian franc", "comorian-franc" ],
          [
            "VEF",
            "Bs",
            "Venezuelan bolívar fuerte",
            "venezuelan-bolívar-fuerte"
          ],
          [ "LRD", "$", "Liberian dollar", "liberian-dollar" ],
          [ "PYG", "Gs", "Paraguayan guarani", "paraguayan-guarani" ],
          [ "LTC", "", "Litecoin", "litecoin" ],
          [ "EUR", "€", "Euro", "euro" ],
          [ "SGD", "$", "Singapore dollar", "singapore-dollar" ],
          [ "XOF", "", "Cfa franc bceao", "cfa-franc-bceao" ],
          [ "CNH", "", "Chinese yuan (offshore)", "chinese-yuan-(offshore)" ],
          [ "SEK", "kr", "Swedish krona", "swedish-krona" ],
          [ "XPT", "", "Platinum ounce", "platinum-ounce" ],
          [ "AZN", "₼", "Azerbaijani manat", "azerbaijani-manat" ],
          [ "DASH", "", "Dash", "dash" ],
          [ "ZEC", "", "Zcash", "zcash" ],
          [ "BCH", "", "Bitcoin cash", "bitcoin-cash" ],
          [ "BOB", "$b", "Bolivian boliviano", "bolivian-boliviano" ],
          [ "EGP", "£", "Egyptian pound", "egyptian-pound" ],
          [ "MVR", "", "Maldivian rufiyaa", "maldivian-rufiyaa" ],
          [ "SVC", "$", "Salvadoran colón", "salvadoran-colón" ],
          [ "NAD", "$", "Namibian dollar", "namibian-dollar" ],
          [ "JEP", "£", "Jersey pound", "jersey-pound" ],
          [ "UZS", "лв", "Uzbekistan som", "uzbekistan-som" ],
          [ "GNF", "", "Guinean franc", "guinean-franc" ],
          [ "GBP", "£", "British pound sterling", "british-pound-sterling" ],
          [ "USDC", "", "Usd coin", "usd-coin" ],
          [ "RWF", "", "Rwandan franc", "rwandan-franc" ],
          [ "NZD", "$", "New zealand dollar", "new-zealand-dollar" ],
          [ "FJD", "$", "Fijian dollar", "fijian-dollar" ],
          [
            "STD",
            "",
            "São tomé and príncipe dobra (pre 2018)",
            "são-tomé-and-príncipe-dobra-(pre-2018)"
          ],
          [ "MNT", "₮", "Mongolian tugrik", "mongolian-tugrik" ],
          [ "BHD", "BD", "Bahraini dinar", "bahraini-dinar" ],
          [ "XAG", "", "Silver ounce", "silver-ounce" ],
          [ "VUV", "VT", "Vanuatu vatu", "vanuatu-vatu" ],
          [ "ZWL", "$", "Zimbabwean dollar", "zimbabwean-dollar" ],
          [ "BND", "$", "Brunei dollar", "brunei-dollar" ],
          [ "IQD", "د.ع", "Iraqi dinar", "iraqi-dinar" ],
          [ "DOP", "RD$", "Dominican peso", "dominican-peso" ],
          [ "MOP", "MOP$", "Macanese pataca", "macanese-pataca" ],
          [ "JOD", "", "Jordanian dinar", "jordanian-dinar" ],
          [ "XPF", "", "Cfp franc", "cfp-franc" ],
          [ "FKP", "£", "Falkland islands pound", "falkland-islands-pound" ],
          [
            "AED",
            "فلس",
            "United arab emirates dirham",
            "united-arab-emirates-dirham"
          ],
          [ "SDG", "", "Sudanese pound", "sudanese-pound" ],
          [ "UAH", "₴", "Ukrainian hryvnia", "ukrainian-hryvnia" ],
          [ "XCD", "$", "East caribbean dollar", "east-caribbean-dollar" ],
          [ "WAVES", "", "Waves", "waves" ],
          [ "TJS", "", "Tajikistani somoni", "tajikistani-somoni" ],
          [ "IRR", "﷼", "Iranian rial", "iranian-rial" ],
          [ "BTC", "₿", "Bitcoin", "bitcoin" ],
          [ "KZT", "лв", "Kazakhstani tenge", "kazakhstani-tenge" ],
          [ "MYR", "RM", "Malaysian ringgit", "malaysian-ringgit" ],
          [ "ZAR", "R", "South african rand", "south-african-rand" ],
          [ "CUC", "$", "Cuban convertible peso", "cuban-convertible-peso" ],
          [ "XAU", "", "Gold ounce", "gold-ounce" ],
          [ "LSL", "", "Lesotho loti", "lesotho-loti" ],
          [ "WST", "$", "Samoan tala", "samoan-tala" ],
          [ "BZD", "BZ$", "Belize dollar", "belize-dollar" ],
          [ "MMK", "K", "Myanma kyat", "myanma-kyat" ],
          [ "AFN", "؋ ", "Afghan afghani", "afghan-afghani" ],
          [ "BWP", "P", "Botswanan pula", "botswanan-pula" ],
          [
            "TTD",
            "TT$",
            "Trinidad and tobago dollar",
            "trinidad-and-tobago-dollar"
          ],
          [ "ETH", "", "Ethereum", "ethereum" ],
          [ "MWK", "MK", "Malawian kwacha", "malawian-kwacha" ],
          [ "USDT", "", "Tether", "tether" ],
          [ "XDR", "", "Special drawing rights", "special-drawing-rights" ],
          [
            "CLF",
            "",
            "Chilean unit of account (uf)",
            "chilean-unit-of-account-(uf)"
          ],
          [ "CVE", "$", "Cape verdean escudo", "cape-verdean-escudo" ],
          [ "NOK", "kr", "Norwegian krone", "norwegian-krone" ],
          [ "KYD", "$", "Cayman islands dollar", "cayman-islands-dollar" ],
          [ "RON", "lei", "Romanian leu", "romanian-leu" ],
          [ "PLN", "zł", "Polish zloty", "polish-zloty" ],
          [ "CUP", "₱", "Cuban peso", "cuban-peso" ],
          [ "ILS", "₪", "Israeli new sheqel", "israeli-new-sheqel" ],
          [ "HTG", "G", "Haitian gourde", "haitian-gourde" ],
          [
            "STN",
            "",
            "São tomé and príncipe dobra",
            "são-tomé-and-príncipe-dobra"
          ],
          [ "VND", "₫", "Vietnamese dong", "vietnamese-dong" ],
          [ "MXN", "$", "Mexican peso", "mexican-peso" ],
          [ "THB", "฿", "Thai baht", "thai-baht" ],
          [ "GEL", "", "Georgian lari", "georgian-lari" ],
          [ "GYD", "$", "Guyanaese dollar", "guyanaese-dollar" ],
          [ "BRL", "R$", "Brazilian real", "brazilian-real" ],
          [ "ISK", "kr", "Icelandic króna", "icelandic-króna" ],
          [ "AUD", "$", "Australian dollar", "australian-dollar" ],
          [ "COP", "$", "Colombian peso", "colombian-peso" ],
          [ "MKD", "ден", "Macedonian denar", "macedonian-denar" ],
          [ "SHP", "£", "Saint helena pound", "saint-helena-pound" ],
          [ "LBP", "£", "Lebanese pound", "lebanese-pound" ],
          [ "BYN", "Br", "Belarusian ruble", "belarusian-ruble" ],
          [ "ERN", "", "Eritrean nakfa", "eritrean-nakfa" ],
          [ "KHR", "៛", "Cambodian riel", "cambodian-riel" ],
          [
            "ANG",
            "ƒ",
            "Netherlands antillean guilder",
            "netherlands-antillean-guilder"
          ],
          [ "TWD", "NT$", "New taiwan dollar", "new-taiwan-dollar" ],
          [ "SCR", "₨", "Seychellois rupee", "seychellois-rupee" ],
          [ "UGX", "UGX", "Ugandan shilling", "ugandan-shilling" ],
          [ "MGA", "Ar", "Malagasy ariary", "malagasy-ariary" ],
          [ "HUF", "Ft", "Hungarian forint", "hungarian-forint" ],
          [ "LKR", "₨", "Sri lankan rupee", "sri-lankan-rupee" ],
          [ "GMD", "", "Gambian dalasi", "gambian-dalasi" ],
          [ "NIO", "C$", "Nicaraguan córdoba", "nicaraguan-córdoba" ],
          [ "CLP", "$", "Chilean peso", "chilean-peso" ],
          [ "GTQ", "Q", "Guatemalan quetzal", "guatemalan-quetzal" ],
          [ "OMR", "﷼", "Omani rial", "omani-rial" ],
          [ "AOA", "Kz", "Angolan kwanza", "angolan-kwanza" ],
          [ "NPR", "₨", "Nepalese rupee", "nepalese-rupee" ],
          [ "DZD", "", "Algerian dinar", "algerian-dinar" ],
          [ "KRW", "", "South korean won", "south-korean-won" ],
          [ "HRK", "kn", "Croatian kuna", "croatian-kuna" ],
          [ "PAB", "B/.", "Panamanian balboa", "panamanian-balboa" ],
          [ "YER", "﷼", "Yemeni rial", "yemeni-rial" ],
          [ "GIP", "£", "Gibraltar pound", "gibraltar-pound" ],
          [ "IMP", "£", "Manx pound", "manx-pound" ],
          [ "MAD", "", "Moroccan dirham", "moroccan-dirham" ],
          [ "XPD", "", "Palladium ounce", "palladium-ounce" ],
          [ "CRC", "₡", "Costa rican colón", "costa-rican-colón" ],
          [ "AMD", "֏", "Armenian dram", "armenian-dram" ],
          [ "PKR", "₨", "Pakistani rupee", "pakistani-rupee" ],
          [ "SYP", "£", "Syrian pound", "syrian-pound" ],
          [ "NGN", "₦", "Nigerian naira", "nigerian-naira" ],
          [ "TND", "", "Tunisian dinar", "tunisian-dinar" ],
          [ "MUR", "₨", "Mauritian rupee", "mauritian-rupee" ],
          [ "EOS", "", "Eos", "eos" ],
          [ "DJF", "$", "Djiboutian franc", "djiboutian-franc" ],
          [ "RSD", "Дин.", "Serbian dinar", "serbian-dinar" ],
          [ "BGN", "лв", "Bulgarian lev", "bulgarian-lev" ],
          [ "UYU", "$U", "Uruguayan peso", "uruguayan-peso" ],
          [ "INR", "₹", "Indian rupee", "indian-rupee" ],
          [ "HUSD", "", "Husd", "husd" ],
          [ "BMD", "$", "Bermudan dollar", "bermudan-dollar" ],
          [ "USD", "$", "United states dollar", "united-states-dollar" ],
          [ "KES", "KSh", "Kenyan shilling", "kenyan-shilling" ],
          [ "RUB", "₽", "Russian ruble", "russian-ruble" ],
          [ "HNL", "L", "Honduran lempira", "honduran-lempira" ],
          [
            "MRO",
            "",
            "Mauritanian ouguiya (pre 2018)",
            "mauritanian-ouguiya-(pre-2018)"
          ],
          [ "SAR", "﷼", "Saudi riyal", "saudi-riyal" ],
          [ "AWG", "ƒ", "Aruban florin", "aruban-florin" ],
          [ "KWD", "ك", "Kuwaiti dinar", "kuwaiti-dinar" ],
          [ "MDL", "", "Moldovan leu", "moldovan-leu" ],
          [ "TRY", "Kr", "Turkish lira", "turkish-lira" ],
          [ "DOGE", "", "Dogecoin", "dogecoin" ],
          [ "JMD", "J$", "Jamaican dollar", "jamaican-dollar" ],
          [ "JPY", "¥", "Japanese yen", "japanese-yen" ],
          [ "SOS", "S", "Somali shilling", "somali-shilling" ],
          [ "CAD", "$", "Canadian dollar", "canadian-dollar" ],
          [
            "VES",
            "",
            "Venezuelan bolívar soberano",
            "venezuelan-bolívar-soberano"
          ],
          [ "GGP", "£", "Guernsey pound", "guernsey-pound" ],
          [ "SSP", "", "South sudanese pound", "south-sudanese-pound" ],
          [ "CZK", "Kč", "Czech republic koruna", "czech-republic-koruna" ],
          [ "PHP", "₱", "Philippine peso", "philippine-peso" ],
          [ "KPW", "₩", "North korean won", "north-korean-won" ],
          [
            "BAM",
            "KM",
            "Bosnia herzegovina convertible mark",
            "bosnia-herzegovina-convertible-mark"
          ],
          [ "BTN", "", "Bhutanese ngultrum", "bhutanese-ngultrum" ]
    ]
    
    
    static func hexStringFromColor(color: UIColor) -> String {
       let components = color.cgColor.components
       let r: CGFloat = components?[0] ?? 0.0
       let g: CGFloat = components?[1] ?? 0.0
       let b: CGFloat = components?[2] ?? 0.0

       let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
       return hexString
    }

   static func colorWithHexString(hexString: String) -> UIColor {
       var colorString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
       colorString = colorString.replacingOccurrences(of: "#", with: "").uppercased()

       print(colorString)
       let alpha: CGFloat = 1.0
       let red: CGFloat = colorComponentFrom(colorString: colorString, start: 0, length: 2)
       let green: CGFloat = colorComponentFrom(colorString: colorString, start: 2, length: 2)
       let blue: CGFloat = colorComponentFrom(colorString: colorString, start: 4, length: 2)

       let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
       return color
   }

    static func colorComponentFrom(colorString: String, start: Int, length: Int) -> CGFloat {

       let startIndex = colorString.index(colorString.startIndex, offsetBy: start)
       let endIndex = colorString.index(startIndex, offsetBy: length)
       let subString = colorString[startIndex..<endIndex]
       let fullHexString = length == 2 ? subString : "\(subString)\(subString)"
       var hexComponent: UInt32 = 0

       guard Scanner(string: String(fullHexString)).scanHexInt32(&hexComponent) else {
           return 0
       }
       let hexFloat: CGFloat = CGFloat(hexComponent)
       let floatValue: CGFloat = CGFloat(hexFloat / 255.0)
       print(floatValue)
       return floatValue
   }


 
}


    



 
