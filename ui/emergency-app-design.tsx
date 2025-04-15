import React, { useState } from 'react';
import { Camera, Phone, MapPin, FileText, Heart, AlertCircle, Menu, X, ChevronLeft, User, BookOpen, Home } from 'lucide-react';

export default function EmergencyApp() {
  const [currentScreen, setCurrentScreen] = useState('home');
  const [menuOpen, setMenuOpen] = useState(false);
  
  const screens = {
    home: <HomeScreen navigate={setCurrentScreen} />,
    contacts: <ContactsScreen navigate={setCurrentScreen} />,
    map: <MapScreen navigate={setCurrentScreen} />,
    medical: <MedicalScreen navigate={setCurrentScreen} />,
    documents: <DocumentsScreen navigate={setCurrentScreen} />,
    evacuation: <EvacuationScreen navigate={setCurrentScreen} />
  };
  
  return (
    <div className="relative h-screen w-full bg-gray-50 font-sans overflow-hidden">
      {/* Status Bar */}
      <div className="bg-white h-6 w-full flex justify-between items-center px-4">
        <span className="text-xs font-medium">9:41</span>
        <div className="flex gap-1">
          <span className="text-xs">5G</span>
          <span className="text-xs">100%</span>
        </div>
      </div>
      
      {/* App Content */}
      <div className="h-full pb-16">
        {currentScreen !== 'home' && (
          <div className="bg-white h-12 flex items-center px-4 shadow-sm">
            <button 
              onClick={() => setCurrentScreen('home')}
              className="p-2 rounded-full hover:bg-gray-100"
            >
              <ChevronLeft size={20} />
            </button>
            <h1 className="text-lg font-semibold ml-2 capitalize">{currentScreen}</h1>
          </div>
        )}
        
        {screens[currentScreen]}
      </div>
      
      {/* Bottom Nav */}
      <div className="absolute bottom-0 w-full h-16 bg-white shadow-lg flex justify-around items-center">
        <NavButton icon={<AlertCircle size={24} />} label="SOS" active={false} special={true} />
        <NavButton 
          icon={<Phone size={22} />} 
          label="Contacts" 
          active={currentScreen === 'contacts'} 
          onClick={() => setCurrentScreen('contacts')} 
        />
        <NavButton 
          icon={<MapPin size={22} />} 
          label="Map" 
          active={currentScreen === 'map'} 
          onClick={() => setCurrentScreen('map')} 
        />
        <NavButton 
          icon={<Home size={22} />} 
          label="Evac" 
          active={currentScreen === 'evacuation'} 
          onClick={() => setCurrentScreen('evacuation')} 
        />
        <NavButton 
          icon={<Menu size={22} />} 
          label="More" 
          active={menuOpen} 
          onClick={() => setMenuOpen(!menuOpen)} 
        />
      </div>
      
      {/* Menu Overlay */}
      {menuOpen && (
        <div className="absolute inset-0 bg-black bg-opacity-50" onClick={() => setMenuOpen(false)}>
          <div className="absolute bottom-16 right-0 w-40 bg-white rounded-tl-lg shadow-lg p-2" onClick={e => e.stopPropagation()}>
            <MenuItem 
              icon={<Heart size={18} />} 
              label="Medical" 
              onClick={() => {
                setCurrentScreen('medical');
                setMenuOpen(false);
              }} 
            />
            <MenuItem 
              icon={<FileText size={18} />} 
              label="Documents" 
              onClick={() => {
                setCurrentScreen('documents');
                setMenuOpen(false);
              }} 
            />
            <MenuItem 
              icon={<BookOpen size={18} />} 
              label="Guidelines" 
              onClick={() => {
                setCurrentScreen('guidelines');
                setMenuOpen(false);
              }} 
            />
            <MenuItem 
              icon={<User size={18} />} 
              label="Profile" 
              onClick={() => {
                setCurrentScreen('profile');
                setMenuOpen(false);
              }} 
            />
          </div>
        </div>
      )}
    </div>
  );
}

function HomeScreen({ navigate }) {
  return (
    <div className="h-full flex flex-col p-4">
      <h1 className="text-2xl font-bold text-center mb-6 text-red-600">Emergency Info</h1>
      
      {/* SOS Button */}
      <button className="w-40 h-40 mx-auto mb-8 bg-red-600 rounded-full flex items-center justify-center shadow-lg">
        <div className="w-36 h-36 rounded-full border-4 border-white flex items-center justify-center">
          <span className="text-3xl font-bold text-white">SOS</span>
        </div>
      </button>
      
      {/* Quick Access Tiles */}
      <div className="grid grid-cols-2 gap-4">
        <QuickTile 
          icon={<Phone size={28} />} 
          label="Emergency Contacts" 
          color="bg-blue-500"
          onClick={() => navigate('contacts')}
        />
        <QuickTile 
          icon={<MapPin size={28} />} 
          label="Emergency Locations" 
          color="bg-green-500"
          onClick={() => navigate('map')}
        />
        <QuickTile 
          icon={<Home size={28} />} 
          label="Evacuation Points" 
          color="bg-orange-500"
          onClick={() => navigate('evacuation')}
        />
        <QuickTile 
          icon={<Heart size={28} />} 
          label="Medical Info" 
          color="bg-purple-500"
          onClick={() => navigate('medical')}
        />
      </div>
    </div>
  );
}

function ContactsScreen() {
  return (
    <div className="h-full p-4">
      <div className="bg-white rounded-lg shadow-sm p-4 mb-4">
        <h2 className="text-lg font-semibold mb-2">Emergency Services</h2>
        <ContactItem name="Emergency (Police, Fire, Medical)" number="911" />
        <ContactItem name="Poison Control" number="1-800-222-1222" />
      </div>
      
      <div className="bg-white rounded-lg shadow-sm p-4">
        <h2 className="text-lg font-semibold mb-2">Personal Emergency Contacts</h2>
        <ContactItem name="John Doe (Dad)" number="(555) 123-4567" relationship="Father" />
        <ContactItem name="Jane Doe (Mom)" number="(555) 765-4321" relationship="Mother" />
        <ContactItem name="Dr. Smith" number="(555) 987-6543" relationship="Primary Doctor" />
      </div>
    </div>
  );
}

function MapScreen() {
  return (
    <div className="h-full p-4 flex flex-col">
      <div className="bg-white rounded-lg shadow-sm p-4 mb-4">
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-semibold">Nearby Emergency Services</h2>
          <button className="text-blue-500 text-sm">Refresh</button>
        </div>
      </div>
      
      <div className="flex-1 bg-gray-200 rounded-lg overflow-hidden relative">
        <div className="absolute inset-0 flex items-center justify-center">
          <MapPin size={24} className="text-red-500" />
        </div>
        <div className="absolute bottom-4 left-4 right-4">
          <div className="bg-white rounded-lg shadow-md p-3 mb-2">
            <h3 className="font-medium">City Hospital</h3>
            <p className="text-sm text-gray-600">0.8 miles - 5 min drive</p>
            <div className="flex mt-2">
              <button className="bg-blue-500 text-white text-sm py-1 px-3 rounded">Directions</button>
              <button className="ml-2 text-blue-500 text-sm py-1 px-3 border border-blue-500 rounded">Call</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function EvacuationScreen() {
  return (
    <div className="h-full p-4 flex flex-col">
      <div className="bg-white rounded-lg shadow-sm p-4 mb-4">
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-semibold">Evacuation Points</h2>
          <button className="text-blue-500 text-sm">Refresh</button>
        </div>
      </div>
      
      <div className="flex-1 bg-gray-200 rounded-lg overflow-hidden relative">
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="flex flex-col items-center">
            <Home size={24} className="text-orange-500" />
            <div className="mt-2 text-sm font-medium">Your Location</div>
          </div>
        </div>
        
        {/* Evacuation Points on Map */}
        <div className="absolute top-1/4 right-1/4">
          <div className="bg-orange-500 p-1 rounded-full">
            <Home size={16} className="text-white" />
          </div>
        </div>
        <div className="absolute bottom-1/3 left-1/3">
          <div className="bg-orange-500 p-1 rounded-full">
            <Home size={16} className="text-white" />
          </div>
        </div>
        
        <div className="absolute bottom-4 left-4 right-4">
          <div className="bg-white rounded-lg shadow-md p-3 mb-2">
            <div className="flex items-center">
              <div className="bg-orange-500 p-1 rounded-full mr-2">
                <Home size={16} className="text-white" />
              </div>
              <div>
                <h3 className="font-medium">Community Center</h3>
                <p className="text-sm text-gray-600">1.2 miles - 7 min drive</p>
              </div>
            </div>
            <div className="flex mt-2">
              <button className="bg-blue-500 text-white text-sm py-1 px-3 rounded">Directions</button>
              <button className="ml-2 text-blue-500 text-sm py-1 px-3 border border-blue-500 rounded">Details</button>
            </div>
          </div>
        </div>
      </div>
      
      <div className="mt-4 bg-white rounded-lg shadow-sm p-4">
        <h2 className="text-lg font-semibold mb-2">Saved Evacuation Points</h2>
        <EvacuationItem title="Community Center" distance="1.2 miles" type="Public Shelter" />
        <EvacuationItem title="Central High School" distance="2.4 miles" type="Public Shelter" />
        <EvacuationItem title="Family Meeting Point" distance="0.5 miles" type="Personal" />
      </div>
    </div>
  );
}

function MedicalScreen() {
  return (
    <div className="h-full p-4">
      <div className="bg-white rounded-lg shadow-sm p-4 mb-4">
        <h2 className="text-lg font-semibold mb-2">Personal Information</h2>
        <InfoItem label="Name" value="Alex Johnson" />
        <InfoItem label="Date of Birth" value="01/15/1985" />
        <InfoItem label="Blood Type" value="O+" highlight={true} />
      </div>
      
      <div className="bg-white rounded-lg shadow-sm p-4 mb-4">
        <h2 className="text-lg font-semibold mb-2">Medical Conditions</h2>
        <InfoItem label="Allergies" value="Penicillin, Tree Nuts" highlight={true} />
        <InfoItem label="Conditions" value="Asthma" highlight={true} />
      </div>
      
      <div className="bg-white rounded-lg shadow-sm p-4">
        <h2 className="text-lg font-semibold mb-2">Medications</h2>
        <InfoItem label="Albuterol" value="2 puffs as needed" />
        <InfoItem label="Zyrtec" value="10mg daily" />
      </div>
    </div>
  );
}

function DocumentsScreen() {
  return (
    <div className="h-full p-4">
      <div className="bg-white rounded-lg shadow-sm p-4 mb-4">
        <h2 className="text-lg font-semibold mb-2">Insurance</h2>
        <DocumentItem title="Health Insurance Card" />
        <DocumentItem title="Car Insurance Policy" />
      </div>
      
      <div className="bg-white rounded-lg shadow-sm p-4">
        <h2 className="text-lg font-semibold mb-2">ID Documents</h2>
        <DocumentItem title="Driver's License" />
        <DocumentItem title="Passport" />
      </div>
    </div>
  );
}

function NavButton({ icon, label, active, onClick, special }) {
  return (
    <button 
      className={`flex flex-col items-center justify-center w-16 ${active ? 'text-blue-500' : 'text-gray-600'}`}
      onClick={onClick}
    >
      <div className={`p-1 ${special ? 'bg-red-600 text-white rounded-full' : ''}`}>
        {icon}
      </div>
      <span className="text-xs mt-1">{label}</span>
    </button>
  );
}

function MenuItem({ icon, label, onClick }) {
  return (
    <button 
      className="flex items-center w-full p-2 hover:bg-gray-100 rounded"
      onClick={onClick}
    >
      <span className="mr-2 text-gray-600">{icon}</span>
      <span>{label}</span>
    </button>
  );
}

function QuickTile({ icon, label, color, onClick }) {
  return (
    <button 
      className="bg-white rounded-xl shadow-sm overflow-hidden flex flex-col items-center p-4"
      onClick={onClick}
    >
      <div className={`${color} text-white p-3 rounded-full mb-2`}>
        {icon}
      </div>
      <span className="text-sm font-medium text-center">{label}</span>
    </button>
  );
}

function ContactItem({ name, number, relationship }) {
  return (
    <div className="border-b border-gray-100 py-3 last:border-0 flex justify-between items-center">
      <div>
        <p className="font-medium">{name}</p>
        {relationship && <p className="text-xs text-gray-500">{relationship}</p>}
      </div>
      <button className="bg-blue-500 text-white rounded-full p-2">
        <Phone size={16} />
      </button>
    </div>
  );
}

function InfoItem({ label, value, highlight }) {
  return (
    <div className="border-b border-gray-100 py-2 last:border-0">
      <p className="text-sm text-gray-500">{label}</p>
      <p className={`font-medium ${highlight ? 'text-red-600' : ''}`}>{value}</p>
    </div>
  );
}

function DocumentItem({ title }) {
  return (
    <div className="border-b border-gray-100 py-3 last:border-0 flex justify-between items-center">
      <div className="flex items-center">
        <FileText size={20} className="text-gray-400 mr-2" />
        <p className="font-medium">{title}</p>
      </div>
      <button className="text-blue-500">View</button>
    </div>
  );
}

function EvacuationItem({ title, distance, type }) {
  return (
    <div className="border-b border-gray-100 py-3 last:border-0 flex justify-between items-center">
      <div className="flex items-center">
        <div className="bg-orange-500 p-1 rounded-full mr-2">
          <Home size={16} className="text-white" />
        </div>
        <div>
          <p className="font-medium">{title}</p>
          <p className="text-xs text-gray-500">{distance} • {type}</p>
        </div>
      </div>
      <button className="bg-blue-500 text-white rounded-full p-2">
        <MapPin size={16} />
      </button>
    </div>
  );
}
