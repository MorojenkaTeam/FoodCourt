//
//  RecipeTableModel.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 02.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

let recipeData: [Recipe] = [
    Recipe(id: "0", authorId: "0", name: "Винегрет", description: "12345", imageData: "https://avatars.mds.yandex.net/get-zen_doc/1132604/pub_5c66afb3fec61f00b2b818d5_5c66afed39ce5700af962765/scale_1200", rating: 4.2),
    Recipe(id: "1", authorId: "1", name: "Оливье с мазиком", description: "Фуууууууууууууууууучччччччччччччччч", imageData: "https://avatars.mds.yandex.net/get-pdb/2980440/9ff1f39d-4214-4660-aef8-2e82355e5a3b/s1200", rating: 1.4),
    Recipe(id: "2", authorId: "2", name: "Шашлычок", description: "Мммммммм", imageData: "https://xoxu.ru/wp-content/uploads/2019/03/IMG_0107.jpg", rating: 4.9)
]

protocol RecipeTableModelProtocol {
    func loadRecipes(completion: (([Recipe]?) -> Void)?)
    //func loadImageData(from url: URL, completion: ((Data?) -> Void)?)
}

class RecipeTableModel: RecipeTableModelProtocol {
    //static let shared = RecipeTableModel()
    
    //private init() {}
    
    func loadRecipes(completion: (([Recipe]?) -> Void)?) {
        completion?(recipeData)
    }
    
    /*func loadImageData(from url: URL, completion: ((Data?) -> Void)?) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion?(nil)
                return
            }
            
            completion?(data)
        }.resume()
    }*/
}
