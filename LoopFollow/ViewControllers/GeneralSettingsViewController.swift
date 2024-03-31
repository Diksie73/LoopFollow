//
//  GeneralSetingsViewController.swift
//  LoopFollow
//
//  Created by Jose Paredes on 7/16/20.
//  Copyright © 2020 Jon Fawcett. All rights reserved.
//

import Foundation
import Eureka
import EventKit
import EventKitUI

class GeneralSettingsViewController: FormViewController {
   
   var appStateController: AppStateController?
   
   override func viewDidLoad()  {
      super.viewDidLoad()
      
      if UserDefaultsRepository.forceDarkMode.value {
         overrideUserInterfaceStyle = .dark
      }
      buildGeneralSettings()

      // Register the GeneralSettingsViewController as an observer for the UIApplication.willEnterForegroundNotification, which will be triggered when the app enters the foreground. This helps ensure that the "Speak BG" switch in the General Settings is updated according to the current setting.
      NotificationCenter.default.addObserver(self, selector: #selector(handleAppWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
   }
   
   private func buildGeneralSettings() {
      form
        +++ Section("App Settings")
        <<< SwitchRow("appBadge"){ row in
            row.title = "Display App Badge"
            row.tag = "appBadge"
            row.value = UserDefaultsRepository.appBadge.value
        }.onChange { [weak self] row in
                    guard let value = row.value else { return }
                    UserDefaultsRepository.appBadge.value = value
                    // Force main screen update
                    //guard let mainScreen = self?.tabBarController!.viewControllers?[0] as? MainViewController else { return }
                    //mainScreen.nightscoutLoader(forceLoad: true)
                    
           // set the appstate to indicate settings change and flags
           if let appState = self!.appStateController {
              appState.generalSettingsChanged = true
              appState.generalSettingsChanges |= GeneralSettingsChangeEnum.appBadgeChange.rawValue
           }
           
        }
        <<< SwitchRow("backgroundRefresh"){ row in
            row.title = "Background Refresh"
            row.tag = "backgroundRefresh"
            row.value = UserDefaultsRepository.backgroundRefresh.value
        }.onChange { [weak self] row in
                    guard let value = row.value else { return }
                    UserDefaultsRepository.backgroundRefresh.value = value
            }
        <<< SwitchRow("persistentNotification") { row in
        row.title = "Persistent Notification"
        row.value = UserDefaultsRepository.persistentNotification.value
        }.onChange { [weak self] row in
            guard let value = row.value else { return }
                UserDefaultsRepository.persistentNotification.value = value
        }
        
        +++ Section("Display Settings")
        <<< SwitchRow("forceDarkMode") { row in
        row.title = "Force Dark Mode (Restart App)"
        row.value = UserDefaultsRepository.forceDarkMode.value
        }.onChange { [weak self] row in
            guard let value = row.value else { return }
            UserDefaultsRepository.forceDarkMode.value = value
             
        }
        <<< SwitchRow("showStats") { row in
        row.title = "Display Stats"
        row.value = UserDefaultsRepository.showStats.value
        }.onChange { [weak self] row in
            guard let value = row.value else { return }
            UserDefaultsRepository.showStats.value = value
            
             // set the appstate to indicate settings change and flags
             if let appState = self!.appStateController {
                appState.generalSettingsChanged = true
                appState.generalSettingsChanges |= GeneralSettingsChangeEnum.showStatsChange.rawValue
             }
        }
        <<< SwitchRow("useIFCC") { row in
        row.title = "Use IFCC A1C"
        row.value = UserDefaultsRepository.useIFCC.value
        }.onChange { [weak self] row in
            guard let value = row.value else { return }
            UserDefaultsRepository.useIFCC.value = value
            
             // set the appstate to indicate settings change and flags
             if let appState = self!.appStateController {
                appState.generalSettingsChanged = true
                appState.generalSettingsChanges |= GeneralSettingsChangeEnum.useIFCCChange.rawValue
             }
        }
        <<< SwitchRow("showSmallGraph") { row in
        row.title = "Display Small Graph"
        row.value = UserDefaultsRepository.showSmallGraph.value
        }.onChange { [weak self] row in
            guard let value = row.value else { return }
            UserDefaultsRepository.showSmallGraph.value = value
             
            // set the appstate to indicate settings change and flags
            if let appState = self!.appStateController {
               appState.generalSettingsChanged = true
               appState.generalSettingsChanges |= GeneralSettingsChangeEnum.showSmallGraphChange.rawValue
            }
        }
        <<< SwitchRow("colorBGText") { row in
        row.title = "Color Main BG Text"
        row.value = UserDefaultsRepository.colorBGText.value
        }.onChange { [weak self] row in
            guard let value = row.value else { return }
            UserDefaultsRepository.colorBGText.value = value
            // Force main screen update
            //guard let mainScreen = self?.tabBarController!.viewControllers?[0] as? MainViewController else { return }
            //mainScreen.setBGTextColor()
            
            // set the appstate to indicate settings change and flags
            if let appState = self!.appStateController {
              appState.generalSettingsChanged = true
              appState.generalSettingsChanges |= GeneralSettingsChangeEnum.colorBGTextChange.rawValue
           }
        }
        
        <<< SwitchRow("screenlockSwitchState") { row in
            row.title = "Keep Screen Active"
            row.value = UserDefaultsRepository.screenlockSwitchState.value
            }.onChange { [weak self] row in
                guard let value = row.value else { return }
                UserDefaultsRepository.screenlockSwitchState.value = value
            }
       
       <<< SwitchRow("showDisplayName") { row in
           row.title = "Show Display Name"
           row.value = UserDefaultsRepository.showDisplayName.value
       }.onChange { [weak self] row in
           guard let value = row.value else { return }
           UserDefaultsRepository.showDisplayName.value = value
           
           if let appState = self!.appStateController {
               appState.generalSettingsChanged = true
               appState.generalSettingsChanges |= GeneralSettingsChangeEnum.showDisplayNameChange.rawValue
           }
       }
        
       +++ Section("Speak BG Settings")
       <<< SwitchRow("speakBG") { row in
           row.title = "Speak BG"
           row.value = UserDefaultsRepository.speakBG.value
       }.onChange { [weak self] row in
           guard let value = row.value else { return }
           UserDefaultsRepository.speakBG.value = value
           self?.updateSpeakBGSettingsVisibility()
       }
       
       <<< SwitchRow("speakBGAlways") { row in
           row.title = "Always"
           row.value = UserDefaultsRepository.speakBGAlways.value
       }.onChange { [weak self] row in
           guard let value = row.value else { return }
           UserDefaultsRepository.speakBGAlways.value = value
           self?.updateSpeakBGSettingsVisibility()
       }
       
       <<< SwitchRow("speakLowBG") { row in
           row.title = "Low"
           row.value = UserDefaultsRepository.speakLowBG.value
       }.onChange { [weak self] row in
           self?.handleLowProactiveLowToggle(row: row, opposingRowTag: "speakProactiveLowBG")
       }
       
       <<< SwitchRow("speakProactiveLowBG") { row in
           row.title = "Proactive Low"
           row.value = UserDefaultsRepository.speakProactiveLowBG.value
       }.onChange { [weak self] row in
           self?.handleLowProactiveLowToggle(row: row, opposingRowTag: "speakLowBG")
       }
       
       <<< SwitchRow("speakHighBG") { row in
           row.title = "High"
           row.value = UserDefaultsRepository.speakHighBG.value
       }.onChange { row in
           guard let value = row.value else { return }
           UserDefaultsRepository.speakHighBG.value = value
       }
       
       +++ ButtonRow() {
          $0.title = "DONE"
       }.onCellSelection { (row, arg)  in
          self.dismiss(animated:true, completion: nil)
       }
       
       // Call to update initial visibility based on current settings
       updateSpeakBGSettingsVisibility()
    }
    
    func updateSpeakBGSettingsVisibility() {
        let alwaysOn = UserDefaultsRepository.speakBGAlways.value
        let speakBGOn = UserDefaultsRepository.speakBG.value
        
        // Determine visibility for "Always", "Low", "Proactive Low", and "High" based on "Speak BG" and "Always"
        let shouldHideAlways = !speakBGOn
        let shouldHideSettings = alwaysOn || !speakBGOn
        
        form.rowBy(tag: "speakBGAlways")?.hidden = Condition(booleanLiteral: shouldHideAlways)
        form.rowBy(tag: "speakBGAlways")?.evaluateHidden()
        
        ["speakLowBG", "speakProactiveLowBG", "speakHighBG"].forEach { tag in
            if let row = form.rowBy(tag: tag) {
                row.hidden = Condition(booleanLiteral: shouldHideSettings)
                row.evaluateHidden()
                row.updateCell()
            }
        }
    }
    
    func handleLowProactiveLowToggle(row: BaseRow, opposingRowTag: String) {
        guard let switchRow = row as? SwitchRow, let value = switchRow.value else { return }
        
        // Update the UserDefaults value for the current row.
        if row.tag == "speakLowBG" {
            UserDefaultsRepository.speakLowBG.value = value
        } else if row.tag == "speakProactiveLowBG" {
            UserDefaultsRepository.speakProactiveLowBG.value = value
        }
        
        // If the current switch is being turned ON, turn the opposing switch OFF.
        if value {
            if let opposingRow = form.rowBy(tag: opposingRowTag) as? SwitchRow {
                opposingRow.value = false
                opposingRow.updateCell()
                
                // Update the UserDefaults value for the opposing row.
                if opposingRowTag == "speakLowBG" {
                    UserDefaultsRepository.speakLowBG.value = false
                } else if opposingRowTag == "speakProactiveLowBG" {
                    UserDefaultsRepository.speakProactiveLowBG.value = false
                }
            }
        }
    }
        
    // Update the "Speak BG" SwitchRow value in the General Settings when the app enters the foreground. This ensures that the switch reflects the current setting in UserDefaultsRepository, even if it was changed using the Home Screen Quick Action while the app was in the background.
    @objc func handleAppWillEnterForeground() {
        if let row = self.form.rowBy(tag: "speakBG") as? SwitchRow {
            row.value = UserDefaultsRepository.speakBG.value
            row.updateCell()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}
