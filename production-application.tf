#declare the provider...
provider "aws" {
  region                  = "us-east-1"
  profile                 = "terraform-user"
}

#create the VPC
resource "aws_vpc" "ProdVPC" {
  cidr_block       = "192.168.0.0/19"
  instance_tenancy = "default"

  tags = {
    Name = "ProdVPC"
  }
   
}




#create required subnets
resource "aws_subnet" "PublicSubnet1" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  cidr_block = "192.168.4.0/23"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  cidr_block = "192.168.6.0/23"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "DMZSubnet1" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  cidr_block = "192.168.0.0/23"
  availability_zone = "us-east-1a"
  tags = {
    Name = "DMZ Subnet 1"
  }
}

resource "aws_subnet" "DMZSubnet2" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  cidr_block = "192.168.2.0/23"
  availability_zone = "us-east-1b"
  tags = {
    Name = "DMZ Subnet 2"
  }
}

resource "aws_subnet" "PrivateSubnet1" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  cidr_block = "192.168.8.0/23"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "PrivateSubnet2" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  cidr_block = "192.168.10.0/23"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private Subnet 2"
  }
}

#create required internet gateway...
resource "aws_internet_gateway" "Prod-IGW" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  tags = {
    Name = "Prod-IGW"
  }
}


#create required eips...
resource "aws_eip" "eip1" {
  vpc      = true
  depends_on = ["aws_internet_gateway.Prod-IGW"]
  
  tags = {
    Name = "eip1"
  }
  
}

resource "aws_eip" "eip2" {
  vpc      = true
  depends_on = ["aws_internet_gateway.Prod-IGW"]
  
  tags = {
    Name = "eip2"
  }
  
}

#create required NAT gatways
resource "aws_nat_gateway" "NATGateway1" {
  allocation_id = "${aws_eip.eip1.id}"
  subnet_id     = "${aws_subnet.PublicSubnet1.id}"

  tags = {
    Name = "NATGateway1"
  }
}


resource "aws_nat_gateway" "NATGateway2" {
  allocation_id = "${aws_eip.eip2.id}"
  subnet_id     = "${aws_subnet.PublicSubnet2.id}"

  tags = {
    Name = "NATGateway2"
  }
}

#create required route tables
resource "aws_route_table" "DMZRouteTable" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Prod-IGW.id}"	
  }

  tags = {
    Name = " DMZRouteTable"
  }
}


resource "aws_route_table" "PublicRouteTable" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Prod-IGW.id}"	
  }

  tags = {
    Name = "PublicRouteTable"
  }
}


resource "aws_route_table" "PrivateRouteTable1" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.NATGateway1.id}"	
  }

  tags = {
    Name = "PrivateRouteTable1"
  }
}


resource "aws_route_table" "PrivateRouteTable2" {
  vpc_id = "${aws_vpc.ProdVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.NATGateway2.id}"	
  }

  tags = {
    Name = "PrivateRouteTable2"
  }
}



#associate subnets with rout-tables...
resource "aws_route_table_association" "routassociation1" {
  subnet_id = "${aws_subnet.DMZSubnet1.id}"
  route_table_id = "${aws_route_table.DMZRouteTable.id}"
}

resource "aws_route_table_association" "routassociation2" {
  subnet_id = "${aws_subnet.DMZSubnet2.id}"
  route_table_id = "${aws_route_table.DMZRouteTable.id}"
}


resource "aws_route_table_association" "routassociation3" {
  subnet_id = "${aws_subnet.PublicSubnet1.id}"
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
}

resource "aws_route_table_association" "routassociation4" {
  subnet_id = "${aws_subnet.PublicSubnet2.id}"
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
}


resource "aws_route_table_association" "routassociation5" {
  subnet_id = "${aws_subnet.PrivateSubnet1.id}"
  route_table_id = "${aws_route_table.PrivateRouteTable1.id}"
}

resource "aws_route_table_association" "routassociation6" {
  subnet_id = "${aws_subnet.PrivateSubnet2.id}"
  route_table_id = "${aws_route_table.PrivateRouteTable2.id}"
}
