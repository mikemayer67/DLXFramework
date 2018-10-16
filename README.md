# DLX Framework
##Swift Dancing Link (DLX) Solver

This repository contains a handful of inter-related Swift frameworks implementing [Donald Knuth's Dancing Link algorithm](https://en.wikipedia.org/wiki/Dancing_Links).  

In addition to a pure DLX solver, this includes wrappers for both Sudoku and Samurai Sudoku.  This code is written in pure Swift and can be used with either OSX or IOS applications.

This repository also holds (*or, hopefully will hold*) both IOS and OSX applications for for both flavors of Sudoku.  

If others would like to contribute, other problems solvable by DLX, please feel free to jump in!

## What is DLX?

The Dancing Links algorithm is an efficient implementation of what Donald Knuth refers to as the more general Algorithm X.  

**Great... what is Algorithm X?**  

Algorithm X is a matrix based approach to finding solutions to the [exact coverage problem](https://en.wikipedia.org/wiki/Exact_cover).

**You're killing me man... what is the exact coverage problem?**

In a nutshell, given some arbitrary set X and a collection (S) composed of unique subsets of X, an exact coverage "solution" is any subcollection (S') where the union of all elements of S' is identical to X and the intersection of any two elements of S' is the empty set.  In other words, S' contains exactly once each element in X.

**So, why do I care?**

According to the Wikipedia page cited above,  

> Due to its NP-completeness, any problem in NP can be reduced to exact cover problems, which then can be solved with techniques such as Dancing Links. However, for some well known problems, the reduction is particularly direct. For instance, the problem of tiling a board with pentominoes, and solving Sudoku can both be viewed as exact cover problems.

I'm not going to pretend I understand how to map any NP-complete problem to an exact cover problem... but I do understand how certain constrained action problems such as tiling a board with predefined shapes (e.g. pentominoes) or solving a Sudoku problem can be mapped to the exact coverage problem.

In these cases, the set X represents a set of constraints which much be satisfied.  More specifically, a set of constraints which must be uniquely satisfied.  The set S represents all of the possible moves or actions that could be taken.  Each S' represents a subset of moves/actions for which each constraint/outcome is achieved exactly once.

In the case of tiling a grid with predefined shapes, X represents each of the spaces in the grid.  S represents all of the possible ways to place one of the shaped pieces somewhere on the grid.  More specificially, each element of S represents the set of grid spaces covered by a particular piece placed on the board at a specific location and orientation.  Each S' represents the set of pieces/locations such that each cell in the grid is covered by exactly one piece.

In the case of Sudoku, X represents 4 sets of 81 constraints (324 constraints total).  The first set of constraints map to individual cells in the 9x9 grid.  Each cell may contain only a single digit.  The second set of constraints map to the 9 rows x 9 digits.  Each row must contain each digit exactly once.  The third set is similar to the second except that it ensures each column contains each digit exactly once.  The final set is similar to the second and third sets excep that it deals with the 9 subgrids (NE,N,NW,W,SW,S,SE,E,center).

**Great, what does this have to do with Algorithm X?**

Algorithm X represents the exact coverage problem as a matrix and provides a mechanism guaranteed to find all possible solutions (i.e. all S').  Each column in the matrix represents a different element of X.  Each row in the matrix represents a different element of S.  A 1 in the matrix means that the row (element of S)  
contains/covers the corresponding column/constraint (element of X)to the column it is in.  A 0 indicates that the row (element of S) does not cover/contain the element of X.

First, initialize the algorithm:

  * set the matrix A as specified above
  * set the partial solution Q to the empty set

Then proceed with the following steps:
  
* 1. If A is empty, record Q as a solution to S'
* 2. Choose a column (c) from A
* 3. For each r such that A(r,c) = 1
  * a. Append r to Q
  * b. Set matrix A' = A
  * c. For each j such that A'(r,j)=1
     * i. remove each row i from A' where A'(i,j) = 1
     * ii. remove column j from A'
  * d. Recursively apply this algorithm on A' 
  * e. Remove r from Q

Note that if a single solution is sought, the algorithm can be terminated in step 1 after reporting Q as a solution.

**And what about DLX?**

Dancing links is an implementation of Algorithm X which "replaces" the matrix with a set of double linked nodes (or in this case mesh) which represent the 1's in the matrix.  Its power comes from the ability to easily remove a node from the list/mesh and to just as easily reinsert it later.

Where in a typical double linked list each node has links to both the next and previous nodes, a double linked mesh has links to left, right, up, and down nodes.

To remove node x from the list (in this case a row):

    x.left.right = x.right 
    x.right.left = x.left
    
*Note that we do not modify x itself.  It "remembers" where it used to fit into the mesh.*

To return node x to the list:

    x.left.right = x
    x.right.left = x

## DLX Implementation

I lied (a little) about what the DLX mesh looks like.  In addition to the grid nodes (those representing 1's in the matrix) there are header nodes (each associated with a column in the matrix) and a root node.

* Grid nodes are connected with left/right linkage to other grid nodes in the same row in the matrix.  They are connected with up/down linkage to other grid nodes in the same column in the matrix.

* A single header node is inserted between the first and last grid nodes of each column using up/down linkage. The header nodes are connected together with left/right linkage.  Each header node contains an additional attribute (size) tracking the number of grid nodes in the column.  Each grid cell has an additional link (col) which points to the header node associated with the column in which the cell lies.

* The root node is inserted between the first and last header nodes.

Using this double linked mesh, we no longer need to work with recursive copies of the matrix (step 3b).  We can simply remove rows and columns (steps 3c) and then later reinsert them before going on to the next row in step 3.

As an additinal performance enhancement, we take advantage of the tracking of number of rows available to each column. Specifically, at each level of the algorithm we choose a column (step 2) with the least number of associated rows:

At each level (k) of the algorithm, perform the following:

    set c = root.right
    
    if c = root (step 1)
    |  record solution Q
    |  return (or exit if only one solution is desired)
      
    otherwise
    |  set j = c.right
    |  while j != root
    |  |  set c = j if j.size < c.size
    |    
    |  cover column c
    |  
    |  set r = c.down
    |  while r != c  (step 3)
    |  |  append r to Q  (step 3.a)
    |  |
    |  |  set j = r.right
    |  |  while j != r
    |  |  |  cover column j (step 3.c)
    |  |  |  set j = j.right
    |  |    
    |  |  perform search at level (k+1)
    |  | 
    |  |  removed r from Q
    |  |
    |  |  set j = r.left
    |  |  while j != r 
    |  |  |  uncover column j
    |  |  |  set j = j.left
    |  |    
    |  |  r = r.down
    |   
    |  uncover column c
      
To cover column c is to remove it and all associated rows from the mesh:

    set c.right.left = c.left
    set c.left.right = c.right
    
    set i = c.down
    while i != c
    |  set j = i.right
    |  while j != i
    |  |  set j.down.up = j.up
    |  |  set j.up.dwon = j.down
    |  |  decrement j.col.size by 1
    |  |  set j = j.right
    |  set i = down
        
To uncover column c is to reinsert it into the mesh (this must be done in reverse order of covering it)

    set i = c.up
    while i != c
    |  set j = i.left
    |  while j != i
    |  |  set j.down.up = j
    |  |  set j.up.down = j
    |  |  increment j.col.size by 1
    |  |  set j = j.left
    |  set i = i.up
    
    set c.right.left = c
    set c.left.right = c
    
**VOILA**
