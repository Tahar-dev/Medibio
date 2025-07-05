import { Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Technician } from './schemas/technician.schema';
import * as bcrypt from 'bcryptjs';
import { JwtService } from '@nestjs/jwt';
import { SignUpDto } from './dto/signup.dto';
import { LoginDto } from './dto/login.dto';
import { UpdateTechnicianDto } from './dto/update.dto';

@Injectable()
export class TechnicianService {
  constructor(
    @InjectModel(Technician.name)
    private technicianModel: Model<Technician>, 
    private jwtService: JwtService, 
  ) {}

  
  async signUp(signUpDto: SignUpDto): Promise<{ token: string }> {
    const { name,realname, email, password, age , speciality, profil, fcmlist } = signUpDto;

   
    const hashedPassword = await bcrypt.hash(password, 10);

   
    const technician = await this.technicianModel.create({
      name,
      realname,
      email,
      age,
      speciality,
      profil,
      password: hashedPassword,
      fcmlist,
    });

    
    const token = this.jwtService.sign({ id: technician._id });

    
    return { token };
  }

  
  async login(loginDto: LoginDto): Promise<{_id: string; token: string; name :string ; age: number; speciality: string; profil: string; realname: string; fcmlist:string[]}> {
    const { email, password } = loginDto;

   
    const technician = await this.technicianModel.findOne({ email });

    
    if (!technician) {
     
      throw new UnauthorizedException('Invalid email or password');
    }

    const isPasswordMatched = await bcrypt.compare(password, technician.password);

   
    if (!isPasswordMatched) {
      throw new UnauthorizedException('Invalid email or password');
    }

   
    const token = this.jwtService.sign({ id: technician._id });
   
    console.debug('Connected');
    return { _id: technician._id , token, name:technician.name , age:technician.age , speciality:technician.speciality, 
      profil:technician.profil,realname:technician.realname,fcmlist:technician.fcmlist};
  }


  async updateTechnician(
    id: string,
    updateTechnicianDto: UpdateTechnicianDto,
  ): Promise<Technician> {
    const { name, email, password, age, speciality, profil,fcmlist } = updateTechnicianDto;

    let hashedPassword;
    if (password) {
      hashedPassword = await bcrypt.hash(password, 10);
    }

    const updatedTechnician = await this.technicianModel.findByIdAndUpdate(
      id,
      {
        name,
        email,
        age,
        speciality,
        profil,
        ...(password && { password: hashedPassword }),
        fcmlist
      },
      { new: true, runValidators: true },
    );

    if (!updatedTechnician) {
      throw new NotFoundException(`Technician with ID ${id} not found`);
    }

    return updatedTechnician;
  }

  async updateTechnicianByName(
    name: string,
    updateTechnicianDto: UpdateTechnicianDto,
  ): Promise<Technician> {
    // 1. Vérifiez d'abord si le technicien existe
    const existingTech = await this.technicianModel.findOne({ name });
    if (!existingTech) {
      throw new NotFoundException(`Technician with name ${name} not found`);
    }
  
    // 2. Préparez les données de mise à jour
    const updateData: any = { ...updateTechnicianDto };
    
    if (updateData.password) {
      updateData.password = await bcrypt.hash(updateData.password, 10);
    }
  
    // 3. Mettez à jour en utilisant le nom comme filtre
    const updated = await this.technicianModel.findOneAndUpdate(
      { name }, // Filtre par name
      updateData,
      { new: true, runValidators: true }
    );
  
    return updated;
  }
  async getAllTechnicians(): Promise<Technician[]> {
    return this.technicianModel.find().exec();
  }

  async getTechnicianById(id: string): Promise<Technician> {
    const technician = await this.technicianModel.findById(id).exec();
    if (!technician) {
      throw new NotFoundException(`Technician with ID ${id} not found`);
    }
    return technician;
  }


  async findByNom(name: string): Promise<Technician> {
    const technicien = await this.technicianModel.findOne({ name: name }).exec();
    if (!technicien) throw new NotFoundException('Technicien non trouvé');
    return technicien;
  }

async deleteTechnicianById(id: string): Promise<void> {
  const result = await this.technicianModel.findByIdAndDelete(id).exec();
  if (!result) {
    throw new NotFoundException(`Technician with ID ${id} not found`);
  }
}
}
