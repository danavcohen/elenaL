import system'io;
import extensions;
import extensions'text;
import system'routines;
import extensions'routines;


static dir = new Variable();
 

public print(str){
console.printLine(str);
}

setGlobalDir(){
dir.Value := getDir();
}

public program()    
{
var fileName := retFileName();
setGlobalDir();
vmToAsm(fileName);

 
 console.readChar();
}


public vmToAsm(vmFileName){

    var fileAsmName := newFileAsmName(vmFileName);
    var fileNameWithoutPathAndWithoutEnd := getFileNameOnly(vmFileName);
     var fileNameVmToAsmConverter := dir.Value+"\vmToAsmOne.txt";
    var vmToAsmArray := fileVmAsmToArray(fileNameVmToAsmConverter);
    var indexCommand :=0;
    using(auto reader := File.assign(vmFileName).textreader())
    {
          // repeating until all the lines are read 
        while (reader.Available)
        {
           string vmCommand := reader.readLine();
           var asmsCommandsInOneLine := getCorrectAsmCommandFromVmToAsmOneWordArray(vmCommand,vmToAsmArray,fileNameWithoutPathAndWithoutEnd,indexCommand);
           writeAsmsCommandsToFile(fileAsmName,asmsCommandsInOneLine);           
           indexCommand := indexCommand + 1;
        }
                   
    }; 
}



fileVmAsmToArray(fileName){
 var dynamicArray := new system'collections'ArrayList();
 using(auto reader := File.assign(fileName).textreader())
    {
       var i:=1;
        while (reader.Available)
        {
            var lineInFile := reader.readLine();
                dynamicArray.append:lineInFile;           
        }
     };
     ^dynamicArray;
}

public getCorrectAsmCommandFromVmToAsmOneWordArray(vmCommand,vmToAsmArray,fileNameOnly,indexCommand){
      string vmCommandFixedNewLine:= giveVmCommandWitoutNewLineProblem(vmCommand);
      if(stringIsCommand(vmCommandFixedNewLine)){
        auto it := vmToAsmArray.enumerator(); // initializing an enumerator
        while (it.next()) // going through each member
        {
   
          string correntCommandFromFileConvert := it.get(); // getting the current enumeration item
       vmCommandFixedNewLine:= giveVmCommandWitoutNewLineProblem(vmCommand);
            var arrayOfTheConvertFile:= getArrayFromStringWithPartition(correntCommandFromFileConvert,"%");
            var vmCommandInConvertFileInCorrentLine := arrayOfTheConvertFile[0].toString();
            var asmCommandsInConvertFileInCorrentLine := arrayOfTheConvertFile[1].toString();
            string asmCommandsLineAsmFixed :=asmCommandsInConvertFileInCorrentLine; //if not need fixed
             if(ifVmCommandIsBiggerThanOneWord(vmCommandInConvertFileInCorrentLine)){
               asmCommandsLineAsmFixed := addAsmCommandsOutPutIfNeed(asmCommandsInConvertFileInCorrentLine,vmCommandFixedNewLine,fileNameOnly);
               vmCommandFixedNewLine := fixedVmThreeWord(vmCommandFixedNewLine);
              };  
             if(vmCommandInConvertFileInCorrentLine == vmCommandFixedNewLine)
             {
               asmCommandsLineAsmFixed := putCommandIndex(indexCommand,asmCommandsLineAsmFixed);
              ^asmCommandsLineAsmFixed;
             };
     };
     };
     ^"";// if there is a command that not have , or comments.
     
}
public stringIsCommand(str){
    if (stringNotEmpty(str)&&stringIsNotComment(str))
    {
        ^ true;
    };
    ^false;
 }
public stringIsNotComment(str){
 var bm := new StringBookmark(str);
 if(bm.find("//")){^false;};
^true;

}
public putCommandIndex(indexCommand,asmCommands){
  string fixedAsm := asmCommands.replace("$i",indexCommand.toString());
  ^fixedAsm;
}
public ifVmCommandIsBiggerThanOneWord(vmCommand){

var partition := " ";
var vmArray := getArrayFromStringWithPartition(vmCommand,partition);
^vmArray.Length > 1;
}
public fixedVmThreeWord(vmCommand){
    if(vmCommandNeedFixed(vmCommand)){
var partition := " ";
var vmArray := getArrayFromStringWithPartition(vmCommand,partition);
string vmFixed := vmArray[0].toString() + " " + vmArray[1].toString();
^vmFixed;
    };
^vmCommand;
}
public vmCommandNeedFixed(vmCommand){
if(vmCommand != "pop pointer 1" && vmCommand != "push pointer 1" &&vmCommand != "push pointer 0"  && vmCommand != "pop pointer 0")
{
    ^true;
};
^false;

}
public giveVmCommandWitoutNewLineProblem(vmCommand){
                 
 wide newLineSymbol := forward newLine;
 ^vmCommand.replace(newLine,"");
}


public addAsmCommandsOutPutIfNeed(asmCommandsInConvertFileInCorrentLine,vmCommand,fileName){
string partition := " ";
var vmCommandArray := getArrayFromStringWithPartition(vmCommand,partition);
string newAsmCommandsFixed;
if(checkIfSizeOfArrayIsBiggerThanOne(vmCommandArray)== true)
    {
       newAsmCommandsFixed := asmCommandsReplace(asmCommandsInConvertFileInCorrentLine,vmCommandArray[2].toString(),fileName);
       ^newAsmCommandsFixed;
       
     };

    newAsmCommandsFixed := asmCommandsInConvertFileInCorrentLine;//no change!
    ^newAsmCommandsFixed;
}
public asmCommandsReplace(strNeedChange,changeInCommand,fileName){
    string fixedAsm := strNeedChange.replace("x",changeInCommand);
    fixedAsm := fixedAsm.replace("$C",fileName);
    ^fixedAsm;


}



public checkIfSizeOfArrayIsBiggerThanOne(array){
//    if(array.Length
    ^array.Length > 1;

}
public writeAsmsCommandsToFile(fileAsmName,asmCommands){
    if(stringNotEmpty(asmCommands)){
    var newLine:= "^";
    var asmArray := getArrayFromStringWithPartition(asmCommands,newLine);
    writeTheArrayAsmToTheFile(asmArray,fileAsmName);
    
    }
    
}



public writeTheArrayAsmToTheFile(asmArray,fileAsmName){
    var numOfMulti;
       asmArray.forEach:(item){
      if(ifHaveMulti(item)){
              numOfMulti := getNumOfMulti(item);   
      string itemFixed := getTheFixedCommandWithoutMulti(item);
    writeToFileXTimes(fileAsmName,itemFixed,numOfMulti);
   }
   else{
      writeToFile(fileAsmName,item);
      };
   };
 }
public getTheFixedCommandWithoutMulti(str){

    string partition := "*";
    var arrayCheck := getArrayFromStringWithPartition(str,partition);
    if(arrayCheck.Length >1){
     ^arrayCheck[0].toString();
     };
     ^str;
}
public ifHaveMulti(str){
    string partition := "*";
    var arrayCheck := getArrayFromStringWithPartition(str,partition);
    if(arrayCheck.Length >1){
     ^true;
     };
     ^false;
}
public getNumOfMulti(str){
    string partition := "*";
    var arrayCheck := getArrayFromStringWithPartition(str,partition);
     ^stringToInt(arrayCheck[1].toString());


}
public stringToInt(str){
^str.toInt();
}
public writeToFileXTimes(fileName,item,times){
   for(int n := 0, n < times, n += 1)
    {
        writeToFile(fileName,item);
    } 

}
public writeTheArrayToFile(array,fileAsmName){
    
   array.forEach:(item){
   writeToFile(fileAsmName,item);//write the asm to asm file.
   }
 }




public getArrayFromStringWithPartition(string,partition){
^string.splitBy(partition);    
}



public writeToFile(fileName,dataToWrite){
 //using(auto writer := File.assign(fileName).textwriter()){
     using(auto writer := File.assign(fileName).logger()){
writer.writeLine(dataToWrite);
};
}
public retFileName(){
    print("please write your file name include the path:");
 ^ console.readLine();
}

public getDir(){
    print("please write your path:");
 ^ console.readLine();
}
public newFileAsmName(fileName){   
 string newFileName := fileName;    
    newFileName := newFileName.replace("vm", "asm");
    ^ newFileName;
}

public getFileNameOnly(fileName){   
 string newFileName := fileName;    
    newFileName := newFileName.replace(".vm", "");
    var arrayOfName := getArrayFromStringWithPartition(newFileName,"\");
    newFileName:= arrayOfName[arrayOfName.Length-1];
    ^ newFileName;
}


public stringNotEmpty(s){

if(s!= ""){
    ^true;
    };
    ^false;
    }





























public getCorrectAsmCommandFromVmToAsmOneWordArray11111(vmCommand,vmToAsmArray){
    wide newLineSymbol := forward newLine;
//    print(vmCommand.replace(newLine,""));
     string vmCommand2:=vmCommand.replace(newLine,"");
         vmToAsmArray.forEach:(item)
        {
   
        string correntCommandFromFileConvert := item;
        var array:= correntCommandFromFileConvert.splitBy(" ");
          var vmCommandInCorrentLine :=array[0].toString();
                      //print(vmCommand2);
                      //print(vmCommandInCorrentLine);
                      //print(vmCommandInCorrentLine.toString() == vmCommand2.toString());
                     // print("sub"=="sub");
           if(vmCommandInCorrentLine == vmCommand2)
           {
             // string asmCommand := correntCommandFromFileConvert.replace(vmCommandInCorrentLine,"");
              ^correntCommandFromFileConvert.replace(vmCommandInCorrentLine,"");

            //  ^asmCommand;
           }
            
        }

}

public getCorrectAsmCommandFromVmToAsmOneWordFile(vmCommand){
  var fileVmToAsmOneWordName := dir.Value+"vmToAsmOne.txt";
        
    using(auto reader := File.assign(fileVmToAsmOneWordName).textreader())
    {
           
        while (reader.Available)
        {
        string correntCommandFromFileConvert := reader.readLine();
        var array:= correntCommandFromFileConvert.splitBy(" ");
           var vmCommandInCorrentLine :=array[0].toString();
           if(vmCommandInCorrentLine == vmCommand)
           {
              var asmCommand := correntCommandFromFileConvert.replace(vmCommandInCorrentLine,"");
              ^asmCommand;
           }
           
        }
       //   var a:= 1;
     //  ^vmCommand;
     
           
   }; 
   
}

printFile(fileName)
{
using(auto reader := File.assign("C:\Dan\studies programs\elena\elena-4.0.2e.i386-win\tar\tar1\dir\a.asm").textreader())
  {
  while (reader.Available)
    {
      print(reader.readLine());
    }
  };
}
     
  
public LineFirstVmToAsm(fileName){

}

public testString2(){
    
    string s := "mysubstring";    
    s := s.replace("sub", "SUB");
    console.writeLine(s)
}
public testString(){
  // var bm := new StringBookmark(fileName)
//   if(bm.find("vm")){bm.delete("vm").insert("asm")}
  // print(bm.find("vm"));
    var str:="abc def hhh";
    var array:= str.splitBy(" ");
     array.forEach:(item){
         console.printLine(item);}
}
public test(){
 string s:= "sub";
 string p:=" ";
 var array :=  getArrayFromStringWithPartition(s,p);
 print(array[0].toString());   
}