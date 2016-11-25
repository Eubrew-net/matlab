## aggregate.m Documentation

This function is similar to accumarray, but it allows a bit more flexibility in the grouping variable, and allows the grouped variable to include more than one column.

### Syntax

```
[xcon, yagg] = aggregate(x, y)
[xcon, yagg] = aggregate(x, y, fun)
```

### Example

Group timeseries data by month.

```matlab
% Some sample data

t = datenum(2014,1,1) + rand(100,1)*365*2;
y = rand(100,2);

% Aggregate by month

dv = datevec(t);

[mnyr, ymonthly] = aggregate(dv(:,1:2), y)
```

```
mnyr =

        2014           1
        2014           2
        2014           3
        2014           4
        2014           5
        2014           6
        2014           7
        2014           8
        2014           9
        2014          10
        2014          11
        2014          12
        2015           1
        2015           2
        2015           3
        2015           4
        2015           5
        2015           6
        2015           7
        2015           8
        2015           9
        2015          10
        2015          11
        2015          12


ymonthly = 

    [6x2 double]
    [2x2 double]
    [5x2 double]
    [4x2 double]
    [4x2 double]
    [6x2 double]
    [6x2 double]
    [2x2 double]
    [3x2 double]
    [3x2 double]
    [2x2 double]
    [3x2 double]
    [6x2 double]
    [3x2 double]
    [6x2 double]
    [4x2 double]
    [4x2 double]
    [6x2 double]
    [2x2 double]
    [5x2 double]
    [2x2 double]
    [6x2 double]
    [4x2 double]
    [6x2 double]
```