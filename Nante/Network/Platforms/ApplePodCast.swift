//
//  ApplePodCast.swift
//  Nante
//
//  Created by 谷内洋介 on 2023/09/03.
//

import Foundation
import SwiftSoup


struct ApplePodCast: Platform{
    private (set) var input: URL = URL(string: "text")!
    private (set) var title: String?
    private (set) var resourceURL: URL?
    private (set) var publishDate: Date?
    private (set) var duration: Double?
    private (set) var platformSpecificMetadata: String?
    let itunesRSS = ItunesRSSURL()
    
    mutating func parseInput(input: URL) {
        self.input = input
        
        if let htmlText = String(data: try! Data(contentsOf: input), encoding: .utf8){
//        if let htmlText = fetchHTML() {
            if let h1 = extractH1(htmlText){
                self.title = h1
            }
        }

        guard let rssURL = itunesRSS.makeURL(input: self.input) else {
            return
        }
        guard let RSSFeed = String(data: try! Data(contentsOf: rssURL), encoding: .utf8) else {
//        guard let RSSFeed = fetchRSSFeed(url: rssURL) else {
            return
        }
        parseRSSFeed(RSSFeed)
    }
    
    private func fetchHTML()-> String?{
        var html_string: String?
        var hasError: Bool = false
        simple_fetch(url: self.input) { html, error in
        if let e = error {
                hasError = true
            } else if let h = html {
                html_string = h
            }
        }
        if hasError {
            return nil
        }
        return html_string
    }
    
    private func extractH1(_ htmlText: String)-> String?{
        do {
            let doc: Document = try SwiftSoup.parse(htmlText)
            let h1: Element = try doc.select("h1").first()!
            let h1_string: String = try h1.text()
            return h1_string
        } catch {
            return nil
        }
    }
    private func fetchRSSFeed(url: URL) -> String? {
        var xml_string: String?
        var hasError: Bool = false
        simple_fetch(url: url) { xml, error in
            if let e = error {
                hasError = true
            } else if let xml = xml {
                xml_string = xml
            }
        }
        if hasError {
            return nil
        }
        return xml_string
    }
    
    mutating private func parseRSSFeed(_ rssFeed: String){
        // sample RSSFeed: https://anchor.fm/s/6c6909bc/podcast/rss
        guard let doc = try? SwiftSoup.parse(rssFeed, "", Parser.xmlParser()) else { return }
        guard let items: Elements = try? doc.getElementsByTag("item") else { return } // 各エピソード
        guard let h1Title = self.title else { return }
        for item: Element in items.array(){
            guard let xmlTitle:String = getXMLElementString(xmlElement: item, tagName: "title") else { return }
            if (!(h1Title.contains(xmlTitle) || xmlTitle.contains(h1Title))){
                continue
            }
            // url文字列を取得
            guard let resourceURLString = getXMLAttributeString(xmlElement: item, tagName: "enclosure", attrName: "url") else {return}
            // URL形式に変換
            guard let url = URL(string: resourceURLString) else { return }
            self.resourceURL = url
            
            // 発行日の文字列を取得
            guard let publishDateString = getXMLElementString(xmlElement: item, tagName: "pubDate") else { return }
            
            // Date形式に変換
            guard let publishDate = dateFromString(publishDateString) else { return }
            self.publishDate = publishDate
            
            // durationの文字列を取得
            guard let durationString = getXMLElementString(xmlElement: item, tagName: "itunes|duration") else { return }
            
            // TimeIntervalに変換
            guard let duration = timeInterval(from: durationString) else {return}
            self.duration = duration
            break
        }

        // チャンネル名を取得
        // channelタグの中のtitleダグを参照
        guard let channnelTitle = getXMLElementStringByCSSSelector(xml: doc, cssSelector: "channel > title") else { return }
        self.platformSpecificMetadata = channnelTitle
    }
    
    private func getXMLElementStringByCSSSelector(xml:Document, cssSelector:String)->String?{
        guard let element:Element = try? xml.select(cssSelector).first() else {
            return nil
        }
        let elementString = try? element.text()
        return elementString
    }
    
    private func getXMLElementString(xmlElement:Element, tagName:String)->String?{
        guard let element:Element = try? xmlElement.select(tagName).first() else {
            return nil
        }
        let elementString = try? element.text()
        return elementString
    }
    
    private func getXMLAttributeString(xmlElement: Element, tagName: String, attrName: String)->String?{
        guard let element:Element = try? xmlElement.select(tagName).first() else {
            return nil
        }
        let attrString = try? element.attr(attrName)
        return attrString
    }
    
    private func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss 'GMT'"

        return dateFormatter.date(from: dateString)
    }
    private func timeInterval(from timeString: String) -> TimeInterval? {
        let timeParts = timeString.split(separator: ":").compactMap { Double($0) }
        guard timeParts.count == 3 else { return nil }
        
        let hoursToSeconds = timeParts[0] * 3600
        let minutesToSeconds = timeParts[1] * 60
        let seconds = timeParts[2]
        return hoursToSeconds + minutesToSeconds + seconds
    }
}
