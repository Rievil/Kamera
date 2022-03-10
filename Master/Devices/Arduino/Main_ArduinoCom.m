% clear all;
obj=ArduinoObj(25);

OpenConnection(obj);
%%

    LightUp(obj)
%     pause(0.001);
    %%
    GoDark(obj);
%%
TestBoard(obj)
%%
CloseConnection(obj);