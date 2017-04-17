%% Function: makeShpFile

% This function makes a shape file. Input R is the Region Result that is
% produced by runObjectIdentification. The resulting shapefile is in three
% files, .dbf, .shp, and .shx. The naming convention is the name of the
% image file and '_shapes'. 


function shape_struct = makeShpFile(R)

imgName = R.validationData.imageFilename(1:end-4);
dir = ['Z:\data\objectidentification\final_data\Selected_Images\Orthoimagery\' imgName(1:end-3) '\'];
img_File = [dir imgName] ;
[I,res,grid_length,grid_width,coord.nwLat,coord.seLat,coord.nwLon,coord.seLon] = processUSGS(img_File);
imgName = 'Gainesville_01';

BW_shapes = scores;
shape_struct= struct('Geometry',{},'X',{},'Y',{},'CENTROID_X',{},'CENTROID_Y',{},'BoundingBox',{},'POLY_AREA',{});
shape_stats = regionprops(BW_shapes,'Area','Centroid','ConvexHull','Centroid','BoundingBox');

for i=1:numel(shape_stats)
    
    pixX = shape_stats(i).ConvexHull(:,1);
    pixY = shape_stats(i).ConvexHull(:,2);
    [shape_struct(i).X,shape_struct(i).Y] = getLonLat(pixX,pixY,I,coord);%pix2coord(pixX,lat0,lat1,grid_width,1);
    
    pixX_Centroid = shape_stats(i).Centroid(1);
    pixY_Centroid = shape_stats(i).Centroid(2);
    [shape_struct(i).CENTROID_X,shape_struct(i).CENTROID_Y] = getLonLat(pixX_Centroid,pixY_Centroid,I,coord);%pix2coord(pixX_Centroid,lat0,lat1,grid_width,1);
    
    pixBB = shape_stats(i).BoundingBox;
    pixX_BB = [pixBB(1) pixBB(1)+pixBB(3)];
    pixY_BB = [pixBB(2) pixBB(2)+pixBB(4)];
    [ X_BB(1),Y_BB(1)] = getLonLat(pixX_BB(1),pixY_BB(1),I,coord);
    [ X_BB(2),Y_BB(2)] = getLonLat(pixX_BB(2),pixY_BB(2),I,coord);
    Y_BB = getLonLat();
    shape_struct(i).BoundingBox = [X_BB(1) Y_BB(1) X_BB(2) Y_BB(2)];
    
    shape_struct(i).POLY_AREA = shape_stats(i).Area;
    shape_struct(i).Geometry = 'Polygon';
end

dbfspec = makedbfspec(shape_struct);

shapewrite(shape_struct, [imgName '_shapes.shp'], 'DbfSpec', dbfspec);


end
