//
//  Report.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 14.11.2021.
//

import Foundation
import UIKit
import CoreData

enum ReportProcess: Int
{
    case ReportProcessAll = 0
    case ReportProcessList = 1
    case ReportProcessHistory = 2
}

class Report: NSObject
{
    var cvfListMeasure_1: AnyObject!
    var cvfListMeasure_10: AnyObject!
    var cvfListMeasure_11: AnyObject!
    var cvfListMeasure_11_xx: AnyObject!
    var cvfListMeasure_2: AnyObject!
    var cvfListMeasure_3: AnyObject!
    var cvfListMeasure_3_1: AnyObject!
    var cvfListMeasure_3_2: AnyObject!
    var cvfListMeasure_4: AnyObject!
    var cvfListMeasure_5: AnyObject!
    var cvfListMeasure_5_1: AnyObject!
    var cvfListMeasure_5_2: AnyObject!
    var cvfListMeasure_5_2_1: AnyObject!
    var cvfListMeasure_5_2_1_1: AnyObject!
    var cvfListMeasure_5_2_1_2: AnyObject!
    var cvfListMeasure_5_2_1_3: AnyObject!
    var cvfListMeasure_5_2_2: AnyObject!
    var cvfListMeasure_5_2_2_1: AnyObject!
    var cvfListMeasure_5_2_2_2: AnyObject!
    var cvfListMeasure_5_2_2_3: AnyObject!
    var cvfListMeasure_6: AnyObject!
    var cvfListMeasure_6_1_1: AnyObject!
    var cvfListMeasure_6_1_2: AnyObject!
    var cvfListMeasure_6_1_3: AnyObject!
    var cvfListMeasure_6_2_1: AnyObject!
    var cvfListMeasure_6_2_2: AnyObject!
    var cvfListMeasure_6_2_3: AnyObject!
    var cvfListMeasure_6_3_1: AnyObject!
    var cvfListMeasure_6_3_2: AnyObject!
    var cvfListMeasure_6_3_3: AnyObject!
    var cvfListMeasure_7: AnyObject!
    var cvfListMeasure_8: AnyObject!
    var cvfListMeasure_8_1: AnyObject!
    var cvfListMeasure_8_2: AnyObject!
    var cvfListMeasure_9: AnyObject!
    var historyDates: AnyObject!
    var historyMeasure_1: AnyObject!
    var historyMeasure_10: AnyObject!
    var historyMeasure_11: AnyObject!
    var historyMeasure_11_xx: AnyObject!
    var historyMeasure_2: AnyObject!
    var historyMeasure_3: AnyObject!
    var historyMeasure_3_1: AnyObject!
    var historyMeasure_3_2: AnyObject!
    var historyMeasure_4: AnyObject!
    var historyMeasure_5: AnyObject!
    var historyMeasure_5_1: AnyObject!
    var historyMeasure_5_2: AnyObject!
    var historyMeasure_5_2_1: AnyObject!
    var historyMeasure_5_2_1_1: AnyObject!
    var historyMeasure_5_2_1_2: AnyObject!
    var historyMeasure_5_2_1_3: AnyObject!
    var historyMeasure_5_2_2: AnyObject!
    var historyMeasure_5_2_2_1: AnyObject!
    var historyMeasure_5_2_2_2: AnyObject!
    var historyMeasure_5_2_2_3: AnyObject!
    var historyMeasure_6: AnyObject!
    var historyMeasure_6_1_1: AnyObject!
    var historyMeasure_6_1_2: AnyObject!
    var historyMeasure_6_1_3: AnyObject!
    var historyMeasure_6_2_1: AnyObject!
    var historyMeasure_6_2_2: AnyObject!
    var historyMeasure_6_2_3: AnyObject!
    var historyMeasure_6_3_1: AnyObject!
    var historyMeasure_6_3_2: AnyObject!
    var historyMeasure_6_3_3: AnyObject!
    var historyMeasure_7: AnyObject!
    var historyMeasure_8: AnyObject!
    var historyMeasure_8_1: AnyObject!
    var historyMeasure_8_2: AnyObject!
    var historyMeasure_9: AnyObject!
    var measure_1: AnyObject!
    var measure_10: AnyObject!
    var measure_11: AnyObject!
    var measure_11_xx: AnyObject!
    var measure_2: AnyObject!
    var measure_3: AnyObject!
    var measure_3_1: AnyObject!
    var measure_3_2: AnyObject!
    var measure_4: AnyObject!
    var measure_5: AnyObject!
    var measure_5_1: AnyObject!
    var measure_5_2: AnyObject!
    var measure_5_2_1: AnyObject!
    var measure_5_2_1_1: AnyObject!
    var measure_5_2_1_2: AnyObject!
    var measure_5_2_1_3: AnyObject!
    var measure_5_2_2: AnyObject!
    var measure_5_2_2_1: AnyObject!
    var measure_5_2_2_2: AnyObject!
    var measure_5_2_2_3: AnyObject!
    var measure_6: AnyObject!
    var measure_6_1_1: AnyObject!
    var measure_6_1_2: AnyObject!
    var measure_6_1_3: AnyObject!
    var measure_6_2_1: AnyObject!
    var measure_6_2_2: AnyObject!
    var measure_6_2_3: AnyObject!
    var measure_6_3_1: AnyObject!
    var measure_6_3_2: AnyObject!
    var measure_6_3_3: AnyObject!
    var measure_7: AnyObject!
    var measure_8: AnyObject!
    var measure_8_1: AnyObject!
    var measure_8_2: AnyObject!
    var measure_9: AnyObject!
    var violListMeasure_5: AnyObject!
    var violListMeasure_5_1: AnyObject!
    var violListMeasure_5_2: AnyObject!
    var violListMeasure_5_2_1: AnyObject!
    var violListMeasure_5_2_1_1: AnyObject!
    var violListMeasure_5_2_1_2: AnyObject!
    var violListMeasure_5_2_1_3: AnyObject!
    var violListMeasure_5_2_2: AnyObject!
    var violListMeasure_5_2_2_1: AnyObject!
    var violListMeasure_5_2_2_2: AnyObject!
    var violListMeasure_5_2_2_3: AnyObject!
    var violListMeasure_6: AnyObject!
    var violListMeasure_6_1_1: AnyObject!
    var violListMeasure_6_1_2: AnyObject!
    var violListMeasure_6_1_3: AnyObject!
    var violListMeasure_6_2_1: AnyObject!
    var violListMeasure_6_2_2: AnyObject!
    var violListMeasure_6_2_3: AnyObject!
    var violListMeasure_6_3_1: AnyObject!
    var violListMeasure_6_3_2: AnyObject!
    var violListMeasure_6_3_3: AnyObject!
    var violListMeasure_7: AnyObject!
    var refuseListMeasure_5_2_2: AnyObject!
    var refuseListMeasure_5_2_2_1: AnyObject!
    var refuseListMeasure_5_2_2_2: AnyObject!
    var refuseListMeasure_5_2_2_3: AnyObject!
    var refuseListMeasure_6_1_3: AnyObject!
    var refuseListMeasure_6_2_3: AnyObject!
    var refuseListMeasure_6_3_3: AnyObject!
    var refuseListMeasure_7: AnyObject!
    
    
    
    
    func format() -> NSArray
    {
        let formattedReport: NSMutableArray = []
        do
        {
            try self.tryFormat(formattedReport: formattedReport)
        }
        catch
        {
            let reason = "Ошибка формирования отчета!"
            print(reason)
        }
        
        let disableReasons = CoreDataStack.sharedInstance.getDisableReasons()
        
        let disable: NSMutableArray = []
        for i in 0..<disableReasons.count
        {
            do
            {
                try tryDisableReasons(disable: disable, disableReasons: disableReasons, i:i)
            }
            catch
            {
                let reason = "Ошибка формирования отчета!"
                print(reason)
            }
        }
        
        do
        {
            try tryDisableReasons2(disable: disable)
        }
        catch
        {
            let reason = "Ошибка формирования отчета!"
            print(reason)
        }
        
        do
        {
            try tryFormattedReport(formattedReport: formattedReport, disable: disable)
        }
        catch
        {
            let reason = "Ошибка формирования отчета!"
            print(reason)
        }
        return formattedReport
    }
    
    func tryDisableReasons(disable: NSMutableArray, disableReasons: NSArray, i: Int) throws
    {
        let test = ((self.cvfListMeasure_11_xx as! NSDictionary)[(String((disableReasons[i] as! DisableReason).id))] as AnyObject).count ?? 0
        print(test)
        disable.add([
                        (disableReasons[i] as! DisableReason).name!,
                        ((self.cvfListMeasure_11_xx as! NSDictionary)[(String((disableReasons[i] as! DisableReason).id))] as AnyObject).count ?? 0,
                        [
                            "История" : Constant.notNil(obj: self.historyMeasure_11_xx[(String((disableReasons[i] as! DisableReason).id))] as AnyObject)
                        ],
                        []])
    }
    
    func tryDisableReasons2(disable: NSMutableArray) throws
    {
        disable.add(["причина неработоспособности комплекса неизвестна",
                     ((self.cvfListMeasure_11_xx as! NSDictionary)["0"] as AnyObject).count ?? 0,
                     [
                        "История" : Constant.notNil(obj: ((self.historyMeasure_11_xx as! NSDictionary)["0"] as AnyObject))
                     ],
                     []
        ])
    }
    
    func tryFormattedReport(formattedReport: NSMutableArray, disable: NSMutableArray) throws
    {
        formattedReport.addObjects(from:
                                    [
                                        "СОСТОЯНИЕ НЕРАБОТАЮЩИХ КОМПЛЕКСОВ ВФ",
                                        [
                                            "Неработающие КВФ (не передают данные в систему \"Трафик\")",
                                            self.cvfListMeasure_11.count ?? 0,
                                            [
                                                "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_11),
                                                "История" : Constant.notNil(obj: self.historyMeasure_11)
                                            ],
                                            disable
                                        ]
                                    ])
        print("reportSuccess")
    }
    
    func tryFormat(formattedReport: NSMutableArray) throws
    {
        formattedReport.addObjects(from:
                                    ["ПОКАЗАТЕЛИ РАБОТОСПОСОБНОСТИ КОМПЛЕКСОВ ВФ И СРЕДСТВ ПЕРЕДАЧИ ДАННЫХ",
                                     ["Общее количество КВФ",
                                      self.cvfListMeasure_1.count!,
                                      [
                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_1),
                                        "История" : Constant.notNil(obj: self.historyMeasure_1)],
                                      [],
                                     ],
                                     [
                                        "Не работают",
                                        self.cvfListMeasure_2.count!,
                                        [
                                            "Список КВФ": Constant.notNil(obj: self.cvfListMeasure_2),
                                            "История" : Constant.notNil(obj: self.historyMeasure_2)],
                                        [],
                                     ],
                                     ["Передают данные для обработки в ЦАФАП",
                                      self.cvfListMeasure_3.count!,
                                      [
                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_3),
                                        "История" : Constant.notNil(obj: historyMeasure_3)
                                      ],
                                      [
                                        ["с регистрацией нарушений",
                                         self.cvfListMeasure_3_1.count!,
                                         [
                                            "Список КВФ": Constant.notNil(obj: self.cvfListMeasure_3_1),
                                            "История" : Constant.notNil(obj: self.historyMeasure_3_1)
                                         ],
                                         []
                                        ],
                                        [
                                            "без регистрации нарушений",
                                            self.cvfListMeasure_3_2.count!,
                                            [
                                                "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_3_2),
                                                "История" : Constant.notNil(obj: self.historyMeasure_3_2)
                                            ],
                                            []
                                        ]
                                      ]
                                     ],
                                     "РЕЗУЛЬТАТЫ РАБОТЫ КОМПЛЕКСОВ ВФ",
                                     [
                                        "Зарегистрировано количество проездов",
                                        self.getSum(dict: self.cvfListMeasure_4 as! NSDictionary),
                                        [
                                            "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_4),
                                            "История" : Constant.notNil(obj: self.historyMeasure_4)
                                        ],
                                        []
                                     ],
                                     [
                                        "Зарегистрировано количество нарушений",
                                        self.getSum(dict: self.cvfListMeasure_5 as! NSDictionary),
                                        [
                                            "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5),
                                            "История" : Constant.notNil(obj: self.historyMeasure_5),
                                            "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5)
                                        ],
                                        [
                                            [
                                                "оформлено",
                                                self.getSum(dict: self.cvfListMeasure_5_1 as! NSDictionary),
                                                [
                                                    "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5_1),
                                                    "История" : Constant.notNil(obj: self.historyMeasure_5_1),
                                                    "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5_1)
                                                ],
                                                []
                                            ],
                                            [
                                                "не оформлено",
                                                self.getSum(dict: self.cvfListMeasure_5_2 as! NSDictionary),
                                                [
                                                    "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5_2),
                                                    "История" : Constant.notNil(obj: self.historyMeasure_5_2),
                                                    "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5_2)
                                                ],
                                                [
                                                    [
                                                        "не просмотрено",
                                                        self.getSum(dict: self.cvfListMeasure_5_2_1 as! NSDictionary),
                                                        [
                                                            "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5_2_1),
                                                            "История" : Constant.notNil(obj: self.historyMeasure_5_2_1),
                                                            "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5_2_1)
                                                        ],
                                                        [
                                                            [
                                                                "ожидает ответа внешних систем",
                                                                self.getSum(dict: self.cvfListMeasure_5_2_1_1 as! NSDictionary),
                                                                [
                                                                    "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5_2_1_1),
                                                                    "История" : Constant.notNil(obj: self.historyMeasure_5_2_1_1),
                                                                    "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5_2_1_1)
                                                                ],
                                                                []
                                                            ],
                                                            [
                                                                "не просмотрено ЦОДД",
                                                                self.getSum(dict: self.cvfListMeasure_5_2_1_2 as! NSDictionary),
                                                                [
                                                                    "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5_2_1_2),
                                                                    "История" : Constant.notNil(obj: self.historyMeasure_5_2_1_2),
                                                                    "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5_2_1_2)
                                                                ],
                                                                []
                                                            ],
                                                            [
                                                                "просмотрено ЦОДД, но не просмотрено ЦАФАП",
                                                                self.getSum(dict: self.cvfListMeasure_5_2_1_3 as! NSDictionary),
                                                                [
                                                                    "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5_2_1_3),
                                                                    "История" : Constant.notNil(obj: self.historyMeasure_5_2_1_3),
                                                                    "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5_2_1_3)
                                                                ],
                                                                []
                                                            ]
                                                        ]
                                                    ],
                                                    [
                                                        "отказано",
                                                        self.getSum(dict: self.cvfListMeasure_5_2_2 as! NSDictionary),
                                                        [
                                                            "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5_2_2),
                                                            "История" : Constant.notNil(obj: self.historyMeasure_5_2_2),
                                                            "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5_2_2),
                                                            "Причины отказа" : Constant.notNil(obj: self.refuseListMeasure_5_2_2)
                                                        ],
                                                        [
                                                            [
                                                                "отказано ЦОДД",
                                                                self.getSum(dict: self.cvfListMeasure_5_2_2_1 as! NSDictionary),
                                                                [
                                                                    "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5_2_2_1),
                                                                    "История" : Constant.notNil(obj: self.historyMeasure_5_2_2_1),
                                                                    "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5_2_2_1),
                                                                    "Причины отказа" : Constant.notNil(obj: self.refuseListMeasure_5_2_2_1)
                                                                ],
                                                                []
                                                            ],
                                                            [
                                                                "отказано ЦАФАП",
                                                                self.getSum(dict: self.cvfListMeasure_5_2_2_2 as! NSDictionary),
                                                                [
                                                                    "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5_2_2_2),
                                                                    "История" : Constant.notNil(obj: self.historyMeasure_5_2_2_2),
                                                                    "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5_2_2_2),
                                                                    "Причины отказа" : Constant.notNil(obj: self.refuseListMeasure_5_2_2_2)
                                                                ],
                                                                []
                                                            ],
                                                            [
                                                                "отказано автоматически",
                                                                self.getSum(dict: self.cvfListMeasure_5_2_2_3 as! NSDictionary),
                                                                [
                                                                    "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_5_2_2_3),
                                                                    "История" : Constant.notNil(obj: self.historyMeasure_5_2_2_3),
                                                                    "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_5_2_2_3),
                                                                    "Причины отказа" : Constant.notNil(obj: self.refuseListMeasure_5_2_2_3)
                                                                ],
                                                                []
                                                            ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                     ]
                                     //                                     ,
                                     
                                    ])
        
        formattedReport.addObjects(from:
                                    [
                                        "РЕЗУЛЬТАТЫ РАБОТЫ ЦОДД, ЦАФАП",
                                        [
                                            "Проверено ЦОДД ВСЕГО",
                                            self.getSum(dict: self.cvfListMeasure_6 as! NSDictionary),
                                            [
                                                "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_6),
                                                "История" : Constant.notNil(obj: self.historyMeasure_6),
                                                "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_6)
                                            ],
                                            [
                                                [
                                                    "проверено для ГИБДД",
                                                    self.getSum(dict: self.cvfListMeasure_6_1_1 as! NSDictionary),
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_6_1_1),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_6_1_1),
                                                        "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_6_1_1)
                                                    ],
                                                    []
                                                ],
                                                [
                                                    "оформлено ГИБДД",
                                                    self.getSum(dict: self.cvfListMeasure_6_1_2 as! NSDictionary),
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_6_1_2),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_6_1_2),
                                                        "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_6_1_2)
                                                    ],
                                                    []
                                                ],
                                                [
                                                    "отказано ГИБДД",
                                                    self.getSum(dict: self.cvfListMeasure_6_1_3 as! NSDictionary),
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_6_1_3),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_6_1_3),
                                                        "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_6_1_3),
                                                        "Причины отказа" : Constant.notNil(obj: self.refuseListMeasure_6_1_3)
                                                    ],
                                                    []
                                                ],
                                                [
                                                    "проверено для АМПП",
                                                    self.getSum(dict: self.cvfListMeasure_6_2_1 as! NSDictionary),
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_6_2_1),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_6_2_1),
                                                        "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_6_2_1)
                                                    ],
                                                    []
                                                ],
                                                [
                                                    "оформлено АМПП",
                                                    self.getSum(dict: self.cvfListMeasure_6_2_2 as! NSDictionary),
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_6_2_2),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_6_2_2),
                                                        "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_6_2_2)
                                                    ],
                                                    []
                                                ],
                                                [
                                                    "отказано АМПП",
                                                    self.getSum(dict: self.cvfListMeasure_6_2_3 as! NSDictionary),
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_6_2_3),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_6_2_3),
                                                        "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_6_2_3),
                                                        "Причины отказа" : Constant.notNil(obj: self.refuseListMeasure_6_2_3)
                                                    ],
                                                    []
                                                ],
                                                [
                                                    "проверено для МАДИ",
                                                    self.getSum(dict: self.cvfListMeasure_6_3_1 as! NSDictionary),
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_6_3_1),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_6_3_1),
                                                        "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_6_3_1)
                                                    ],
                                                    []
                                                ],
                                                [
                                                    "оформлено МАДИ",
                                                    self.getSum(dict: self.cvfListMeasure_6_3_2 as! NSDictionary),
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_6_3_2),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_6_3_2),
                                                        "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_6_3_2)
                                                    ],
                                                    []
                                                ],
                                                [
                                                    "отказано МАДИ",
                                                    self.getSum(dict: self.cvfListMeasure_6_3_3 as! NSDictionary),
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_6_3_3),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_6_3_3),
                                                        "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_6_3_3),
                                                        "Причины отказа" : Constant.notNil(obj: self.refuseListMeasure_6_3_3)
                                                    ],
                                                    []
                                                ]
                                            ]
                                        ],
                                        [
                                            "Отказано ЦОДД ВСЕГО",
                                            self.getSum(dict: self.cvfListMeasure_7 as! NSDictionary),
                                            [
                                                "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_7),
                                                "История" : Constant.notNil(obj: self.historyMeasure_7),
                                                "Виды нарушений" : Constant.notNil(obj: self.violListMeasure_7),
                                                "Причины отказа" : Constant.notNil(obj: self.refuseListMeasure_7)
                                            ],
                                            []
                                        ],
                                        "МЕРОПРИЯТИЯ ПО РЕГИСТРАЦИИ КВФ В ЦАФАП",
                                        [
                                            "Общее кол-во КВФ в ЦАФАП",
                                            self.cvfListMeasure_8.count!,
                                            [
                                                "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_8),
                                                "История" : Constant.notNil(obj: self.historyMeasure_8)
                                            ],
                                            [
                                                [
                                                    "в Справочнике камер с регистрацией нарушений",
                                                    self.cvfListMeasure_8_1.count!,
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_8_1),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_8_1)
                                                    ],
                                                    []
                                                ],
                                                [
                                                    "в Справочнике камер без регистрации нарушений",
                                                    self.cvfListMeasure_8_2.count!,
                                                    [
                                                        "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_8_2),
                                                        "История" : Constant.notNil(obj: self.historyMeasure_8_2)
                                                    ],
                                                    []
                                                ]
                                            ]
                                        ],
                                        [
                                            "КВФ из Справочника камер, не включенные в обработку",
                                            self.cvfListMeasure_9.count!,
                                            [
                                                "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_9),
                                                "История" : Constant.notNil(obj: self.historyMeasure_9)
                                            ],
                                            []
                                        ],
                                        [
                                            "КВФ из Справочника камер с отсутствующим сертификатом поверки",
                                            self.cvfListMeasure_10.count!,
                                            [
                                                "Список КВФ" : Constant.notNil(obj: self.cvfListMeasure_10),
                                                "История" : Constant.notNil(obj: self.historyMeasure_10)
                                            ],
                                            []
                                        ]
                                    ])
    }
    
    
    func getSum(dict: NSDictionary) -> Int
    {
        var sum = 0
        for key in dict.allKeys as! [String]
        {
            sum += dict[key] as! Int
        }
        return sum
    }
}
