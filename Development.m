Skey = 'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM';
% Find connected serial devices and clean up the output
[~, list] = dos(['REG QUERY ' Skey]);
list = string(strread(list,'%s','delimiter',' '));
list(contains(list,Skey))=[];

A=contains(list,"COM");
%%

A = rand(49,49);
A(:,:,2) = rand(49,49);
A(:,:,3) = rand(49,49);
% Write the image data to a JPEG file, specifying the output format using 'jpg'. Add a comment to the file using the 'Comment' name-value pair argument.

imwrite(A,'newImage.jpg','jpg','Comment','My JPEG file');
%%

I=zeros(300,300);
I = insertText(I,[150,150],'Missing image','AnchorPoint','center');
imshow(I);

