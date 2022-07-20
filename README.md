# RadStudio ACRCardReader API

This API used to connect to ACR Series Card  Reader , see example for more info

## ACRCardReader Usage


```bash
uses ACSModule , ACSModule_Ready,...;
```

## Example

```python
type
 TMainForm = class(TForm)
 ... 
 private
    procedure OnCardInserted(Sender: TObject);
    procedure OnCardRemoved(Sender: TObject);
    procedure OnLogMessage(Sender: TObject;Location,Status,Data:String);
    procedure OnCardActive(Sender: TObject);
    procedure OnReaderWaiting(Sender: TObject);
    procedure OnReaderListChange(Sender: TObject);
	procedure OnCardInvalid(Sender: TObject);
    procedure OnProgress(Sender: TObject;Str1:String;Code1:Integer);	
    procedure OnError(Sender: TObject;ErrSource:TErrSource;ErrCode:Cardinal);
 end;
 
var Reader:TACSModule; 



....

begin
	Reader := TACSModule.Create;
	Reader.Debugging:= False;
	Reader.OnCardInserted := OnCardInserted;
	Reader.OnCardRemoved := OnCardRemoved;
	Reader.OnLogMessage := OnLogMessage;
	Reader.OnCardActive := OnCardActive;
	Reader.OnReaderWaiting := OnReaderWaiting;
	Reader.OnReaderListChange := OnReaderListChange;	
	Reader.OnCardInvalid := OnCardInvalid;
	Reader.OnProgress := OnProgress;	
	Reader.OnError := OnError;
	Reader.Init;
end;

```





## License
[MIT](https://choosealicense.com/licenses/mit/)