//
//  SqliteManager.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "SqliteManager.h"
#import <sqlite3.h>
@interface SqliteManager(){
    sqlite3 *database;
}
@end

@implementation SqliteManager

- (instancetype)InitSqliteWithName:(NSString *)databaseName{
       NSString *path = [self getPathWithName:databaseName];
       int sqlStatus = sqlite3_open_v2([path UTF8String], &database,SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE,NULL);
       if (sqlStatus == SQLITE_OK) {
           NSLog(@"数据库打开成功");
       }
    return (__bridge SqliteManager *)(database);
       
}
- (void)InitTableWithName:(NSString *)CreateSql database:(sqlite3 *)db{
    const char *sql = [CreateSql UTF8String];
    char *erro = 0;
    int tabelStatus = sqlite3_exec(db, sql,NULL, NULL, &erro);//运行结果
    if (tabelStatus == SQLITE_OK)
    {
        NSLog(@"表打开成功");
    }
}

- (void)InsertDataIntoTable:(NSString *)InsertSql database:(sqlite3 *)db{
    const char *sql = [InsertSql UTF8String];
    char *erro = 0;
    int insertResult = sqlite3_exec(db,sql,NULL,NULL,&erro);
    if(insertResult == SQLITE_OK){
        NSLog(@"添加数据成功");
    }else{
        NSLog(@"插入数据失败");
    }
}
- (void)SelectDataFromTable:(NSString *)SelectSql database:(sqlite3 *)db{}
- (void)DeleteDataFromTable:(NSString *)DeleteSql database:(sqlite3 *)db{}
- (void)UpdataDataFromTable:(NSString *)UpdateSql database:(sqlite3 *)db{}

- (NSString *)getPathWithName:(NSString *)databaseName{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [doc stringByAppendingPathComponent:databaseName];
    NSLog(@"%@",filePath);
    return filePath;
}


@end
