//
//  ViewController.m
//  CoreDataDemo
//
//  Created by lzxuan on 15/9/6.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import "ViewController.h"
#import "UserModel.h"

#import <CoreData/CoreData.h>


@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSManagedObjectContext *_context;//上下文管理对象 对数据库进行增删改查
}
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
    [self coredataInit];
    
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

#pragma mark - CoreData初始化
/*
 1.先创建 数据模型文件 User.xcdatamodeld
    1.1创建数据模型文件-》new file->core Data--》选中Data Model，创建文件 （User.xcdatamodeld）在里面创建 数据模型实例Entity(UserModel)
    1.2再关联创建 相关的数据模型类 UserModel (xcode 中 有相关的CoreData的模板)
 2.初始化 CoreData
    2.1导入头文件#import <CoreData/CoreData.h>
    2.2通过代码获取 获取数据模型文件 (创建对象 NSManagedObjectModel)
 
 
 */

- (void)coredataInit {
    //1.获取数据模型文件
#if 0
    //方法1
    //xxx.xcdatamodeld放在沙盒中变成了xxx.momd 扩展名
    NSString *path = [[NSBundle mainBundle] pathForResource:@"User" ofType:@"momd"];
    NSURL *url = [NSURL fileURLWithPath:path];//把本地资源路径转化为url
    NSManagedObjectModel *modelFile = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    //NSLog(@"%@",path);
#else
    //方法2 ->获取沙盒中 所有的xxx.xcdatamodeld创建成对象
    NSManagedObjectModel *modelFile = [NSManagedObjectModel mergedModelFromBundles:nil];
#endif
    //2.创建 存储协调器
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:modelFile];
    //2.1创建 数据库 (增加存储类型 Sqlite )
    /*
     COREDATA_EXTERN NSString * const NSSQLiteStoreType
     COREDATA_EXTERN NSString * const NSXMLStoreType
     COREDATA_EXTERN NSString * const NSBinaryStoreType
     */
    //URL:写 数据库的路径 在沙盒中路径
    NSError *error = nil;
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dataPath = [doc stringByAppendingPathComponent:@"mydata.sqlite"];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataPath] options:nil error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }
    //3.创建上下文
    _context = [[NSManagedObjectContext alloc] init];
    //给上下文设置存储协调器
    _context.persistentStoreCoordinator = coordinator;
    //初始化完成之后 _context就可以进行增删改查 不用写sql语句
    
}
#pragma mark - 数据库增删改查

- (IBAction)addClick:(id)sender {
    //CoreData中 不要这样 创建model
    //UserModel *model = [[UserModel alloc] init];
    //应该用NSEntityDescription增加数据模型
    UserModel *model = (UserModel *)[NSEntityDescription insertNewObjectForEntityForName:@"UserModel" inManagedObjectContext:_context];
    model.name = self.nameTextField.text;
    model.age = @(self.ageTextField.text.integerValue);
    //增删改 都要 保存数据库
    NSError *error = nil;
    BOOL ret = [_context save:&error];
    if (!ret) {
        //保存失败 返回no
        NSLog(@"error:save->%@",error);
    }
    [self.dataArr addObject:model];
    //刷新
    [self.tableView reloadData];
}

//根据名字 向数据库进行查询
- (NSArray *)findDataWithName:(NSString *)newName {
    //1.创建一个查找请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //1.1设置 查询数据模型
    request.entity  = [NSEntityDescription entityForName:@"UserModel" inManagedObjectContext:_context];
    
    //1.2设置谓词
    //如果 不设置谓词 默认 查询 数据库所有的数据
    if (newName) {
        //如果 newName 有值 根据名字找 设置谓词
        //谓词 @"name like xiaohong"--》表示 查询 数据库 中数据模型 属性name 是 xiaohong的所有的模型对象
        //模糊查询@"name like *xiaohong*"//查询 包含 xiaohong 字符串的name属性
        /*
        NSString *str = [NSString stringWithFormat:@"name like *%@*",newName];
        request.predicate = [NSPredicate predicateWithFormat:str];
        */
        request.predicate = [NSPredicate predicateWithFormat:@"name like %@",newName];
    }
    //1.3设置排序准则(如果需要)
    //实例化排序准则
    //按照 age 属性的值 降序 排列
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:NO];
    
    //按照属性 name 的值 升序排列
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    //如果 按照 sort1排序 age 出现相同 ，那么再按照sort2name 升序排序
    request.sortDescriptors = @[sort1,sort2];
  
    //执行查询 函数
    
    return [_context executeFetchRequest:request error:nil];
}

- (IBAction)deletClick:(id)sender {
    //先找 再删除
    NSArray *arr = [self findDataWithName:self.nameTextField.text];
    ///遍历数组
    for (UserModel *model in arr) {
        //删除找到的
        [_context deleteObject:model];
        //同步tableView
        [self.dataArr removeObject:model];
    }
    [self.tableView reloadData];
    
    //上面 执行的是 从内存 数据库 删除
    //下面 要保存才会 同步到本地
    if (![_context save:nil]) {
        NSLog(@"delete error");
    }
    
}

- (IBAction)updateClick:(id)sender {
    //先找 再修改
    NSArray *arr = [self findDataWithName:self.nameTextField.text];
    ///遍历数组
    for (UserModel *model in arr) {
        model.age = @(self.ageTextField.text.integerValue);
    }
    [self.tableView reloadData];
    
    //下面 要保存才会 同步到本地
    if (![_context save:nil]) {
        NSLog(@"update error");
    }
}

- (IBAction)findName:(id)sender {
    //查找
    NSArray *arr = [self findDataWithName:self.nameTextField.text];
    //放入 数据源
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:arr];
    [self.tableView reloadData];
}

- (IBAction)findAll:(id)sender {
    //查找所有 内容
    NSArray *arr = [self findDataWithName:nil];
    //放入 数据源
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:arr];
    [self.tableView reloadData];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nameTextField resignFirstResponder];
    [self.ageTextField resignFirstResponder];
}
@end







