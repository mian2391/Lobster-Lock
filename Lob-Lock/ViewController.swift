//
//  ViewController.swift
//  Lob-Lock
//
//  Created by Mian Answer on 4/7/17.
//  Copyright © 2017 Lobster Lock LTD. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UIPickerViewDelegate, UIPickerViewDataSource{

    
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var targetService: CBService?
    var writableCharacteristic: CBCharacteristic?
    let serviceUUID = CBUUID(string: "C8BB52AA-63D9-4939-A1E9-DA299CEDCCAB")
    let characteristicUUID = CBUUID(string: "00000000-DC70-4070-DC70-A07BA85EE4D6")
    var num: UInt8 = 0
    var i = 1
    
    @IBOutlet weak var but: UIButton!
    @IBOutlet weak var lab: UILabel!
    @IBOutlet weak var unlock: UIImageView!
    @IBOutlet weak var locked: UIImageView!
    @IBOutlet weak var numPicker: UIPickerView!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var disconnectBtn: UIButton!
    
    let numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(numbers[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        num = UInt8(numbers[row])
        print("\(num)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn(_ sender: Any) {
        if(i == 1) {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
            i = i + 1
            but.setTitle("Stop Scan", for: .normal)
        }
        else {
            centralManager.stopScan()
            i = 1
            but.setTitle("Scan", for: .normal)
        }
    }
    
    @IBAction func sendNumber(_ sender: Any) {
        locked.isHidden = false
        unlock.isHidden = true
        if (connectedPeripheral != nil) {
            var data = Data(bytes: [num])
            connectedPeripheral?.writeValue(data, for: writableCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    @IBAction func disconnectPeripheral(_ sender: Any) {
        disconnect()
    }
    
     func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bletooth on")
            but.isHidden = false
        } else {
            print("no")
            but.isHidden = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        connectedPeripheral = peripheral
        print("did discover")
        print("\(connectedPeripheral?.name)")
        if let connectedPeripheral = connectedPeripheral {
            connectedPeripheral.delegate = self
            print("connecting")
            centralManager.connect(connectedPeripheral, options: nil)
            centralManager.stopScan()
        }
    }
    
   func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect")
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        print("services count= \(services.count)")
        for service in services {
            print("service= \(service.uuid.uuidString)")
        }
        for service in services {
            if (service.uuid.uuidString == serviceUUID.uuidString ) {
            targetService = service
            }
        }
        print("targetService = \(targetService?.uuid.uuidString)")
        peripheral.discoverCharacteristics(nil, for: targetService!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        but.isHidden = true
        send.isHidden = false
        disconnectBtn.isHidden = false
        numPicker.isHidden = false
        for characteristic in characteristics {
            if (characteristic.uuid.uuidString == characteristicUUID.uuidString) {
                writableCharacteristic = characteristic
                //peripheral.setNotifyValue(true, for: characteristic)
            }
        }
         print("characteristic = \(writableCharacteristic?.uuid.uuidString)")
    }
    
    func disconnect () {
       // connectedPeripheral?.setNotifyValue(false, for: writableCharacteristic!)
        centralManager.cancelPeripheralConnection(connectedPeripheral!)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
       print("Disconnected")
        send.isHidden = true
        disconnectBtn.isHidden = true
        numPicker.isHidden = true
        but.setTitle("Scan", for: .normal)
        but.isHidden = false
        locked.isHidden = true
        unlock.isHidden = false
    }
    
}

