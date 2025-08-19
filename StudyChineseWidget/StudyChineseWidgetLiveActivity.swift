//
//  StudyChineseWidgetLiveActivity.swift
//  StudyChineseWidget
//
//  Created by Kosuke Shigematsu on 8/19/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct StudyChineseWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct StudyChineseWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StudyChineseWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension StudyChineseWidgetAttributes {
    fileprivate static var preview: StudyChineseWidgetAttributes {
        StudyChineseWidgetAttributes(name: "World")
    }
}

extension StudyChineseWidgetAttributes.ContentState {
    fileprivate static var smiley: StudyChineseWidgetAttributes.ContentState {
        StudyChineseWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: StudyChineseWidgetAttributes.ContentState {
         StudyChineseWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: StudyChineseWidgetAttributes.preview) {
   StudyChineseWidgetLiveActivity()
} contentStates: {
    StudyChineseWidgetAttributes.ContentState.smiley
    StudyChineseWidgetAttributes.ContentState.starEyes
}
