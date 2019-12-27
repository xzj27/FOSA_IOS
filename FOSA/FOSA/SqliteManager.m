//
//  SqliteManager.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "SqliteManager.h"
#import <sqlite3.h>

@implementation SqliteManager

+ (sqlite3 *)InitSqliteWithName:(NSString *)databaseName{
        sqlite3 *database;
       NSString *path = [self getPathWithName:databaseName];
       int sqlStatus = sqlite3_open_v2([path UTF8String], &database,SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE,NULL);
       if (sqlStatus == SQLITE_OK) {
           NSLog(@"数据库打开成功");
       }
    return database;
}
+ (void)InitTableWithName:(NSString *)CreateSql database:(sqlite3 *)db{
    const char *sql = [CreateSql UTF8String];
    char *erro = 0;
    int tabelStatus = sqlite3_exec(db, sql,NULL, NULL, &erro);//运行结果
    if (tabelStatus == SQLITE_OK)
    {
        NSLog(@"表打开成功");
    }
}
+ (void)InsertDataIntoTable:(NSString *)InsertSql database:(sqlite3 *)db{
    const char *sql = [InsertSql UTF8String];
    char *erro = 0;
    int insertResult = sqlite3_exec(db,sql,NULL,NULL,&erro);
    if(insertResult == SQLITE_OK){
        NSLog(@"添加数据成功");
    }else{
        NSLog(@"插入数据失败");
    }
}
/// 根据选择语句与数据库进行选择操作
/// @param SelectSql 选择语句
/// @param db 数据库实例
+ (sqlite3_stmt *)SelectDataFromTable:(NSString *)SelectSql database:(sqlite3 *)db {
    sqlite3_stmt *stmt;
    const char *selsql = (char *)[SelectSql UTF8String];
    int selresult = sqlite3_prepare_v2(db, selsql, -1, &stmt, NULL);
    if(selresult != SQLITE_OK){
        NSLog(@"select Fail");
        return stmt;
    }else{
        return stmt;
    }
}
+ (int)SelectFromTable:(NSString *)SelectSql database:(sqlite3 *)db stmt:(nonnull sqlite3_stmt *)stmt {
    const char *selsql = (char *)[SelectSql UTF8String];
    int selresult = sqlite3_prepare_v2(db, selsql, -1, &stmt, NULL);
    return selresult;
}

+ (void)DeleteDataFromTable:(NSString *)DeleteSql database:(sqlite3 *)db{
    char * errmsg;
    sqlite3_exec(db, DeleteSql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {
        NSLog(@"删除失败--%s",errmsg);
    }else{
        NSLog(@"删除成功");
    }
}

+ (void)UpdataDataFromTable:(NSString *)UpdateSql database:(sqlite3 *)db{}
+ (NSString *)getPathWithName:(NSString *)databaseName{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [doc stringByAppendingPathComponent:databaseName];
    NSLog(@"%@",filePath);
    return filePath;
}
+ (void)CloseSql:(sqlite3 *)db{
    int close = sqlite3_close_v2(db);
    if (close == SQLITE_OK) {
            db = nil;
    }else{
            NSLog(@"数据库关闭异常");
    }
}

@end
