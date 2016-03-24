//
//  ViewController.m
//  CoreDataDemo
//
//  Created by lzxuan on 15/9/6.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import "ViewController.h"
#import "UserModel.h"
#import "CoreData+MagicalRecord.h"

#import <CoreData/CoreData.h>


@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
- (IBAction)addClick:(id)sender;
- (IBAction)deletClick:(id)sender;
- (IBAction)updateClick:(id)sender;
- (IBAction)findName:(id)sender;
- (IBAction)findAll:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    //初始化 数据源数组
    self.dataArr = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //注册
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}
#pragma mark - 协议方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    UserModel *model = self.dataArr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"name:%@ age:%ld",model.name,model.age.integerValue];
    return cell;
}

#pragma mark - 数据库增删改查

- (IBAction)addClick:(id)sender {
    //增加 数据模型对象
    UserModel *model = [UserModel MR_createEntity];
    model.name = self.nameTextField.text;
    model.age = @(self.ageTextField.text.integerValue);
    
    //同步保存的本地
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    //增加到数据源 刷新表格
    [self.dataArr addObject:model];
    [self.tableView reloadData];
   
}
- (IBAction)deletClick:(id)sender {
    //先 查找
    //根据UserModel 对象的 name 属性 值 查找
    NSArray *arr = [UserModel MR_findByAttribute:@"name" withValue:self.nameTextField.text];
    for (UserModel *model in arr) {
        [model MR_deleteEntity];//把自己从数据库删除
        [self.dataArr removeObject:model];
    }
    //同步保存的本地
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self.tableView reloadData];
}

- (IBAction)updateClick:(id)sender {
    //根据UserModel 对象的 name 属性 值 查找
    NSArray *arr = [UserModel MR_findByAttribute:@"name" withValue:self.nameTextField.text];
    for (UserModel *model in arr) {
        model.age = @(self.ageTextField.text.integerValue);
    }
    //同步保存的本地
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self.tableView reloadData];
}

- (IBAction)findName:(id)sender {
    //根据名字 找 并且 按照 age 降序
    NSArray *arr = [UserModel MR_findByAttribute:@"name" withValue:self.nameTextField.text andOrderBy:@"age" ascending:NO];
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:arr];
    [self.tableView reloadData];
}
- (IBAction)findAll:(id)sender {
    //查询所有的数据  按照  age 降序
    NSArray *arr = [UserModel MR_findAllSortedBy:@"age" ascending:NO];
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:arr];
    [self.tableView reloadData];
   
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nameTextField resignFirstResponder];
    [self.ageTextField resignFirstResponder];
}
@end







